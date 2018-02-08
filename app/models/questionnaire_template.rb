# == Schema Information
#
# Table name: questionnaire_templates
#
#  id                    :integer          not null, primary key
#  region                :string
#  chinese_name          :string
#  english_name          :string
#  simple_chinese_name   :string
#  template_type         :string
#  template_introduction :text
#  questionnaires_count  :integer          default(0)
#  creator_id            :integer
#  comment               :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_questionnaire_templates_on_creator_id  (creator_id)
#

class QuestionnaireTemplate < ApplicationRecord
  include StatementAble
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :questionnaires

  has_many :fill_in_the_blank_questions, dependent: :destroy
  has_many :choice_questions, dependent: :destroy
  has_many :matrix_single_choice_questions, dependent: :destroy

  belongs_to :train_template

  scope :by_creator_name, lambda { |creator_name, lang|
    if creator_name
      creator_ids = User.where("#{lang} like ?", "%#{creator_name}%")
      where(creator_id: creator_ids)
    end
  }

  scope :by_created_date, lambda { |start_date, end_date|
    if start_date && end_date
      where("created_at >= ?", start_date).where("created_at < ?", end_date.to_datetime)
    elsif start_date && !end_date
      where("created_at >= ?", start_date)
    elsif !start_date && end_date
      where("created_at < ?", end_date.to_datetime)
    end
  }

  scope :by_template_type, lambda { |types|
    where(template_type: types) if types
  }

  def simple_chinese_name
    chinese_name
  end

  def self.department_options(questionnaire_template_id)
    Department.where(id: Questionnaire.where(questionnaire_template_id: questionnaire_template_id).joins(:user).select('users.department_id'))
  end

  def self.position_options(questionnaire_template_id)
    Position.where(id: Questionnaire.where(questionnaire_template_id: questionnaire_template_id).joins(:user).select('users.position_id'))
  end

  def self.detail_by_id(id)
    QuestionnaireTemplate
      .includes(:fill_in_the_blank_questions,
                :choice_questions,
                :matrix_single_choice_questions)
      .find(id)
  end

  def self.copy(template_id)
    qt = nil
    ActiveRecord::Base.transaction do
      temp_qt = QuestionnaireTemplate.find(template_id)
      qt = QuestionnaireTemplate.create(temp_qt.slice(*QuestionnaireTemplate.create_params))
      temp_qt.fill_in_the_blank_questions.each do |q|
        qt.fill_in_the_blank_questions.create(q.slice(*FillInTheBlankQuestion.create_params))
      end
      temp_qt.choice_questions.each do |q|
        cq = qt.choice_questions.create(q.slice(*ChoiceQuestion.create_params))
        q.options.each do |option|
          op = cq.options.create(option.slice(*Option.create_params))
          option.attend_attachments.each do |attend_attachment|
            op.attend_attachments.create(attend_attachment.slice(*AttendAttachment.create_params + %w(creator_id)))
          end
        end
      end
      temp_qt.matrix_single_choice_questions.each do |q|
        mq = qt.matrix_single_choice_questions.create(q.slice(*MatrixSingleChoiceQuestion.create_params))
        q.matrix_single_choice_items.each do |item|
          mq.matrix_single_choice_items.create(item.slice(*MatrixSingleChoiceItem.create_params))
        end
      end
    end
    qt
  end

  def self.create_with_params(template_id, fill_in_the_blank_questions_params, choice_questions_params, matrix_single_choice_questions_params, template_type)
    qt = nil
    ActiveRecord::Base.transaction do
      temp_qt = QuestionnaireTemplate.find(template_id)
      qt = QuestionnaireTemplate.create(
        region: temp_qt[:region],
        chinese_name: temp_qt[:chinese_name],
        english_name: temp_qt[:english_name],
        simple_chinese_name: temp_qt[:simple_chinese_name],
        template_introduction: temp_qt[:template_introduction],
        template_type: template_type
      )

      fill_in_the_blank_questions_params.each do |q|
        qt.fill_in_the_blank_questions.create(q.permit(*FillInTheBlankQuestion.create_params))
      end if fill_in_the_blank_questions_params

      choice_questions_params.each do |q|
        cq = qt.choice_questions.create(q.permit(*ChoiceQuestion.create_params))
        cq.answer = q['answer']
        cq.right_answer = q['right_answer']
        cq.save
        options = q['options']
        options.each do |option|
          op = cq.options.create(option.permit(*Option.create_params))
          attachment = option['attend_attachment']
          op.attend_attachments.create(attachment.permit(:file_name, :attachment_id)) if attachment
        end
      end if choice_questions_params

      matrix_single_choice_questions_params.each do |q|
        mq = qt.matrix_single_choice_questions.create(q.permit(*MatrixSingleChoiceQuestion.create_params))
        items = q['matrix_single_choice_items']
        items.each do |item|
          mq.matrix_single_choice_items.create(item.permit(*MatrixSingleChoiceItem.create_params))
        end
      end if matrix_single_choice_questions_params
    end
    qt
  end
end
