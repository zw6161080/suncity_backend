# == Schema Information
#
# Table name: questionnaires
#
#  id                        :integer          not null, primary key
#  region                    :string
#  questionnaire_template_id :integer
#  user_id                   :integer
#  is_filled_in              :boolean
#  release_date              :date
#  release_user_id           :integer
#  submit_date               :date
#  comment                   :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_questionnaires_on_questionnaire_template_id  (questionnaire_template_id)
#  index_questionnaires_on_release_user_id            (release_user_id)
#  index_questionnaires_on_user_id                    (user_id)
#

class Questionnaire < ApplicationRecord
  belongs_to :user
  belongs_to :release_user, :class_name => "User", :foreign_key => "release_user_id"
  belongs_to :questionnaire_template, counter_cache: true
  has_many :fill_in_the_blank_questions, dependent: :destroy
  has_many :choice_questions, dependent: :destroy
  has_many :matrix_single_choice_questions, dependent: :destroy

  scope :by_user_id, lambda { |user_id|
    where(user_id: user_id) if user_id
  }

  scope :by_questionnaire_template_id, lambda { |questionnaire_template_id|
    where(questionnaire_template_id: questionnaire_template_id) if questionnaire_template_id
  }

  scope :by_user_name, lambda { |user_name, lang|
    if user_name
      user_ids = User.where("#{lang} like ?", "%#{user_name}%")
      where(user_id: user_ids)
    end
  }

  scope :by_empoid, lambda { |empoid|
    if empoid
      user_ids = User.where("empoid like ?", "%#{empoid}%")
      where(user_id: user_ids)
    end
  }

  scope :by_release_user_name, lambda { |release_user_name, lang|
    if release_user_name
      release_user_ids = User.where("#{lang} like ?", "%#{release_user_name}%")
      where(release_user_id: release_user_ids)
    end
  }

  scope :by_release_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(release_date: start_date .. end_date)
    elsif start_date && !end_date
      where("release_date > ?", start_date)
    elsif !start_date && end_date
      where("release_date < ?", end_date)
    end
  }

  scope :by_submit_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(submit_date: start_date .. end_date)
    elsif start_date && !end_date
      where("submit_date > ?", start_date)
    elsif !start_date && end_date
      where("submit_date < ?", end_date)
    end
  }

  scope :by_filled_in, lambda { |is_filled_in|
    where(is_filled_in: is_filled_in) if is_filled_in
  }

  scope :by_department_id, lambda { |department_id|
    if department_id
      joins(:user).where(users: { department_id: department_id})
    end
  }

  scope :by_position_id, lambda { |position_id|
    if position_id
      joins(:user).where(users: { position_id: position_id})
    end
  }

  def self.detail_by_id(id)
    Questionnaire
      .includes(:fill_in_the_blank_questions,
                :choice_questions,
                :matrix_single_choice_questions)
      .find(id)
  end

  def detail_json
    re = self.as_json(
      include: {
        user: {include: [:department, :location, :position ]},
        release_user: {},
        questionnaire_template: {},
        fill_in_the_blank_questions: {},
        choice_questions: {include: {options: {include: [:attend_attachments]}}},
        matrix_single_choice_questions: {include: [:matrix_single_choice_items]}
      }
    )

  end

  def self.create_with_params(questionnaire_params,
                              fill_in_the_blank_questions_params,
                              choice_questions_params,
                              matrix_single_choice_questions_params)
    questionnaire = nil
    ActiveRecord::Base.transaction do
      questionnaire = self.create(questionnaire_params.permit(*Questionnaire.create_params))

      fill_in_the_blank_questions_params.each do |question|
        questionnaire.fill_in_the_blank_questions.create(question.permit(*FillInTheBlankQuestion.create_params))
      end if fill_in_the_blank_questions_params

      choice_questions_params.each do |question|
        cq = questionnaire.choice_questions.create(question.permit(*ChoiceQuestion.create_params))
        cq.answer = question['answer']
        cq.save
        options = question['options']
        options.each do |option|
          op = cq.options.create(option.permit(*Option.create_params))
          attachment = option['attend_attachment']
          op.attend_attachments.create(attachment.permit(:file_name, :attachment_id)) if attachment
        end
      end if choice_questions_params

      matrix_single_choice_questions_params.each do |question|
        mq = questionnaire.matrix_single_choice_questions.create(question.permit(*MatrixSingleChoiceQuestion.create_params))
        items = question['matrix_single_choice_items']
        items.each do |item|
          mq.matrix_single_choice_items.create(item.permit(*MatrixSingleChoiceItem.create_params))
        end
      end if matrix_single_choice_questions_params

      questionnaire.save!
    end
    questionnaire.try(:id)
  end

  def update_with_params(questionnaire_params,
                         fill_in_the_blank_questions_params,
                         choice_questions_params,
                         matrix_single_choice_questions_params)
    questionnaire = self
    ActiveRecord::Base.transaction do
      questionnaire.update(questionnaire_params.permit(*Questionnaire.create_params))
      questionnaire.fill_in_the_blank_questions.each { |q| q.destroy }
      questionnaire.choice_questions.each { |q| q.destroy }
      questionnaire.matrix_single_choice_questions.each { |q| q.destroy }

      deal_with_fill_in_the_blank_questions(questionnaire, fill_in_the_blank_questions_params)
      deal_with_choice_questions(questionnaire, choice_questions_params)
      deal_with_matrix_single_choice_questions(questionnaire, matrix_single_choice_questions_params)

      questionnaire.save!
    end
    questionnaire.try(:id)
  end

  def self.create_params
    [:region, :questionnaire_template_id, :user_id, :is_filled_in,
     :release_date, :release_user_id, :submit_date, :comment]
  end

  def deal_with_fill_in_the_blank_questions(questionnaire, fill_in_the_blank_questions_params)
    fill_in_the_blank_questions_params.each do |question|
      questionnaire.fill_in_the_blank_questions.create(question.permit(*FillInTheBlankQuestion.create_params))
    end if fill_in_the_blank_questions_params
  end

  def deal_with_choice_questions(questionnaire, choice_questions_params)
    choice_questions_params.each do |question|
      cq = questionnaire.choice_questions.create(question.permit(*ChoiceQuestion.create_params))
      cq.answer = question['answer']
      cq.save
      options = question['options']
      options.each do |option|
        op = cq.options.create(option.permit(*Option.create_params))
        attachment = option['attend_attachment']
        op.attend_attachments.create(attachment.permit(:file_name, :attachment_id)) if attachment
      end
    end if choice_questions_params
  end

  def deal_with_matrix_single_choice_questions(questionnaire, matrix_single_choice_questions_params)
    matrix_single_choice_questions_params.each do |question|
      mq = questionnaire.matrix_single_choice_questions.create(question.permit(*MatrixSingleChoiceQuestion.create_params))
      items = question['matrix_single_choice_items']
      items.each do |item|
        mq.matrix_single_choice_items.create(item.permit(*MatrixSingleChoiceItem.create_params))
      end
    end if matrix_single_choice_questions_params
  end

  def self.create_with_template(user_id, template)
    if template
      questionnaire = Questionnaire.create(user_id: user_id, questionnaire_template_id: template.id)
    else
      questionnaire = Questionnaire.create(user_id: user_id)
    end

    template.fill_in_the_blank_questions.each do |q|
      questionnaire.fill_in_the_blank_questions.create(q.attributes.merge({ id: nil, questionnaire_template_id: nil }))
    end if template

    template.choice_questions.each do |q|
      cq = questionnaire.choice_questions.create(q.attributes.merge({ id: nil, questionnaire_template_id: nil }))
      cq.answer = q['answer']
      cq.save
      q.options.each do |option|
        op = cq.options.create(option.attributes.merge({ id: nil }))
        option.attend_attachments.each do |attachment|
          op.attend_attachments.create(attachment.attributes.merge({ id: nil }))
        end
      end
    end if template

    template.matrix_single_choice_questions.each do |q|
      mq = questionnaire.matrix_single_choice_questions.create(q.attributes.merge({ id: nil, questionnaire_template_id: nil }))
      q.matrix_single_choice_items.each do |item|
        mq.matrix_single_choice_items.create(item.attributes.merge({ id: nil }))
      end
    end if template
    questionnaire
  end
end
