# == Schema Information
#
# Table name: student_evaluations
#
#  id                :integer          not null, primary key
#  region            :string
#  user_id           :integer
#  employment_status :integer
#  training_type     :integer
#  lecturer_id       :integer
#  evaluation_status :integer
#  filled_in_date    :date
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  train_id          :integer
#  trainer           :string
#  satisfaction      :decimal(15, 2)
#
# Indexes
#
#  index_student_evaluations_on_lecturer_id  (lecturer_id)
#  index_student_evaluations_on_train_id     (train_id)
#  index_student_evaluations_on_user_id      (user_id)
#

class StudentEvaluation < ApplicationRecord
  include StatementAble
  belongs_to :user
  belongs_to :train
  belongs_to :lecturer, :class_name => "User"
  has_one :attend_questionnaire_template, as: :attachable
  has_one :attend_questionnaire, as: :attachable

  has_one :questionnaire, through: :attend_questionnaire
  has_one :questionnaire_template, through: :attend_questionnaire_template

  enum employment_status: { in_service: 0, dimission: 1 }
  enum evaluation_status: { filled_in: 0, unfilled: 1 }

  scope :by_order, lambda {|sort_column, sort_direction|
    if sort_column == :name
      order("users.#{select_language.to_s} #{sort_direction.to_s}")
    else
      order(sort_column => sort_direction)
    end
  }

  scope :order_name, lambda {|args|
    sort_direction = args.first
    order("users.#{select_language.to_s} #{sort_direction.to_s}")
  }

  scope :order_option_id, lambda {| args|
    sort_direction, order_no = args
    joins(questionnaire: :choice_questions).select("student_evaluations.*, choice_questions.answer").where(choice_questions: {order_no: order_no.to_i}).distinct('student_evaluations.id').order(" choice_questions.answer  #{sort_direction.to_s}" )
  }

  scope :order_score, lambda {|args|
    sort_direction, order_no_and_item_no,  = args
    order_no, item_no = order_no_and_item_no.split('.')
    joins(questionnaire: {matrix_single_choice_questions: :matrix_single_choice_items}).where("matrix_single_choice_questions.order_no = :order_no AND matrix_single_choice_items.item_no = :item_no", order_no: order_no.to_i, item_no: item_no.to_i).select("student_evaluations.*, matrix_single_choice_items.score").distinct.order("matrix_single_choice_items.score #{sort_direction.to_s}" )
  }


  scope :join_user_and_questionnaire, lambda {
    joins(:user, :questionnaire)
  }

  scope :by_empoid, lambda { |empoid|
    if empoid
      user_ids = User.where("empoid like ?", "%#{empoid}%")
      where(user_id: user_ids)
    end
  }

  scope :by_user_name, lambda { |name|
    if name
      user_ids = User.where("#{select_language} like ?", "%#{name}%")
      where(user_id: user_ids)
    end
  }

  scope :by_trainer, lambda { |trainer|
    if trainer
      where("trainer like ?", "%#{trainer}%")
    end
  }

  scope :by_name, lambda { |name|
    if name
      user_ids = User.where("#{select_language} like ?", "%#{name}%")
      where(user_id: user_ids)
    end
  }

  scope :by_department, lambda { |department_id|
    if department_id
      user_ids = User.where(department_id: department_id)
      where(user_id: user_ids)
    end
  }

  scope :by_position, lambda { |position_id|
    if position_id
      user_ids = User.where(position_id: position_id)
      where(user_id: user_ids)
    end
  }

  scope :by_employment_status, lambda { |employment_status|
    where(employment_status: employment_status) if employment_status
  }

  scope :by_lecturer, lambda { |name, lang|
    if name
      user_ids = User.where("#{lang} like ?", "%#{name}%")
      where(user_id: user_ids)
    end
  }

  scope :by_satisfaction, lambda { |satisfaction|
    where(satisfaction: satisfaction) if satisfaction
  }

  scope :by_evaluation_status, lambda { |evaluation_status|
    where(evaluation_status: evaluation_status) if evaluation_status
  }

  scope :by_filled_in_date, lambda { |filled_in_date|
    where(filled_in_date: filled_in_date) if filled_in_date
  }

  def self.create_student_evaluations_by_train(train, questionnaire_template_id, current_user)
    result = false
    ActiveRecord::Base.transaction do
      qt = QuestionnaireTemplate.find(questionnaire_template_id)
      train.final_lists&.each do |item|
        se = StudentEvaluation.create(region: item.user.profile.region, user_id: item.user_id, train_id: train.id, evaluation_status: 1)

        user = User.find(item.user_id)
        se.employment_status = ProfileService.is_leave?(user) ? 1 : 0

        se.trainer = train.trainer
        se.save

        q = Questionnaire.create_with_template(item.user_id, qt)
        q.release_user_id = current_user.id
        q.release_date = Time.zone.now.to_date
        q.save

        se.satisfaction = q.matrix_single_choice_questions.count == 0 ? 1 : se.satisfaction

        se.save

        # q = Questionnaire.create!(user_id: item.user_id, questionnaire_template_id: qt.id)
        # q.fill_in_the_blank_questions << qt.fill_in_the_blank_questions
        # q.choice_questions << qt.choice_questions
        # q.matrix_single_choice_questions << qt.matrix_single_choice_questions

        se.create_attend_questionnaire(questionnaire_id: q.id)
        se.create_attend_questionnaire_template!(questionnaire_template_id: qt.id)

        Message.add_notification(train, 'student_evaluation', [item.user_id], {student_evaluation: se.slice(:id)}) if item.user_id
        # Message.add_notification(train, 'student_evaluation', train.final_lists&.pluck(:user_id),{student_evaluation: se.slice(:id)})
      end
      result = true
    end
    result
  end

  scope :by_train, lambda { |train_id|
    where(train_id: train_id) if train_id
  }

  def self.joined_query(train_id)
    self.where(train_id: train_id).join_user_and_questionnaire
  end

  def self.result(query)
    query.first.questionnaire.matrix_single_choice_questions.map {|matrix_single_choice_question|
      matrix_single_choice_question.as_json.merge({
                                                      matrix_single_choice_items: matrix_single_choice_question.matrix_single_choice_items.map {|matrix_single_choice_item|
            matrix_single_choice_item.as_json.merge(
                {
                    figure_result:  {
                        values: values(
                            query, matrix_single_choice_question.order_no, matrix_single_choice_item.item_no
                        ),
                        average_number: average_number(
                            query, matrix_single_choice_question.order_no, matrix_single_choice_item.item_no
                        )
                    }
                }
            )
        }
                                                  })
    }
  end

  def self.values(query,order_no, item_no)
    answer_query = MatrixSingleChoiceQuestion
                       .where(questionnaire_id: query.joins(:questionnaire).pluck('questionnaires.id'))
                       .where(order_no: order_no)
                       .joins(:matrix_single_choice_items).where(matrix_single_choice_items: {item_no: item_no})
    answer_query_count = answer_query.count
    values = []
    MatrixSingleChoiceQuestion
        .where(questionnaire_id: query.joins(:questionnaire).pluck('questionnaires.id')).where(order_no: order_no).first.max_score.times do |i|
      result = BigDecimal(answer_query.where(matrix_single_choice_items: {score: i+1}).count) / BigDecimal(answer_query_count)
      values.push(result.round(2))
    end
    values
  end

  def self.average_number(query, order_no, item_no)
    answer_query = MatrixSingleChoiceQuestion
                       .where(questionnaire_id: query.joins(:questionnaire).pluck('questionnaires.id'))
                       .where(order_no: order_no)
                       .joins(:matrix_single_choice_items).where(matrix_single_choice_items: {item_no: item_no})
    answer_query_count = answer_query.count
    max_score = MatrixSingleChoiceQuestion
                    .where(questionnaire_id: query.joins(:questionnaire).pluck('questionnaires.id'))
                    .where(order_no: order_no).first.max_score
    (BigDecimal(answer_query.sum('matrix_single_choice_items.score')) /  BigDecimal((answer_query_count * max_score)) * BigDecimal(max_score)).round(2)
  end

  def self.department_options(train_id)
    Department.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.department_id'))
  end

  def self.position_options(train_id)
    Position.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.position_id'))
  end

  def self.choice_question_options(option_id)
    ChoiceQuestion.find(option_id).options.map do |item|
      item.as_json.merge({
          chinese_name: item.description,
          english_name: item.description,
          simple_chinese_name: item.description
      })
    end
  end

  def self.matrix_single_choice_items_options(option_id)
    matrix_single_choice_item = MatrixSingleChoiceItem.find(option_id)
    options = []
    matrix_single_choice_item.matrix_single_choice_question.max_score.times do |i|
      options.push({
          id: matrix_single_choice_item.id,
          chinese_name: i+1,
          english_name: i+1,
          simple_chinese_name: i+1
     })
    end
    options
  end

  def self.extra_columns_options(train_id)
    return {} unless train_id
    questionnaire= self.where(train_id: train_id).first.questionnaire
    fill_tag = -1
    fill_in_the_blank_questions = questionnaire.fill_in_the_blank_questions.map do |item|
      fill_tag += 1
      {
          key: item.order_no.to_s,
          chinese_name: item.question,
          english_name: item.question,
          simple_chinese_name: item.question,
          value_type: 'string_value',
          data_index: "questionnaire.fill_in_the_blank_questions.#{fill_tag}.answer"

      }
    end
    choice_tag = -1
    choice_questions = questionnaire.choice_questions.map do|item|
      choice_tag += 1
     {
         key: item.order_no.to_s,
         chinese_name: item.question,
         english_name: item.question,
         simple_chinese_name: item.question,
         value_type: 'array_value',
         item_type: 'option_value',
         item_index: ".",
         join_format: " ",
         data_index: "questionnaire.choice_questions.#{choice_tag}.answer",
         sorter: true,
         search_type: 'screen',
         options_type: 'options',
         options_action: 'choice_question_options',
         option_id: item.id,
         search_attribute: 'option_id'
     }
    end

    matrix_single_tag = -1
    matrix_single_choice_questions = []
    questionnaire.matrix_single_choice_questions.each do |matrix_single_choice_question|
      matrix_single_tag += 1
      matrix_single_item_tag = -1
      matrix_single_choice_question.matrix_single_choice_items.each do |matrix_single_choice_item|
        matrix_single_item_tag += 1
        matrix_single_choice_questions.push( {
            key: "#{matrix_single_choice_question.order_no}.#{matrix_single_choice_item.item_no}",
            chinese_name: matrix_single_choice_item.question,
            english_name: matrix_single_choice_item.question,
            simple_chinese_name: matrix_single_choice_item.question,
            value_type: 'string_value',
            data_index: "questionnaire.matrix_single_choice_questions.#{matrix_single_tag}.matrix_single_choice_items.#{matrix_single_item_tag}.score",
            sorter: true,
            search_type: 'screen',
            options_type: 'options',
            options_action: 'matrix_single_choice_items_options',
            option_id: matrix_single_choice_item.id,
            search_attribute: 'score'
        })
      end
    end
    {
        concat: [fill_in_the_blank_questions&.concat(choice_questions )&.concat(matrix_single_choice_questions)]
    }
  end
end
