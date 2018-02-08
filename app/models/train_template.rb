# == Schema Information
#
# Table name: train_templates
#
#  id                                                     :integer          not null, primary key
#  chinese_name                                           :string
#  english_name                                           :string
#  course_number                                          :string
#  teaching_form                                          :string
#  train_template_type_id                                 :integer
#  training_credits                                       :decimal(15, 2)
#  online_or_offline_training                             :integer
#  limit_number                                           :integer
#  course_total_time                                      :decimal(15, 2)
#  course_total_count                                     :decimal(15, 2)
#  trainer                                                :string
#  language_of_training                                   :string
#  place_of_training                                      :string
#  contact_person_of_training                             :string
#  course_series                                          :string
#  course_certificate                                     :string
#  introduction_of_trainee                                :string
#  introduction_of_course                                 :string
#  goal_of_learning                                       :string
#  content_of_course                                      :string
#  goal_of_course                                         :string
#  assessment_method                                      :integer
#  test_scores_not_less_than                              :decimal(15, 2)
#  exam_format                                            :integer
#  exam_template_id                                       :integer
#  comprehensive_attendance_not_less_than                 :decimal(15, 2)
#  comprehensive_attendance_and_test_scores_not_less_than :decimal(15, 2)
#  test_scores_percentage                                 :decimal(15, 2)
#  notice                                                 :string
#  comment                                                :string
#  creator_id                                             :integer
#  created_at                                             :datetime         not null
#  updated_at                                             :datetime         not null
#  simple_chinese_name                                    :string
#  questionnaire_template_chinese_name                    :string
#  questionnaire_template_english_name                    :string
#  questionnaire_template_simple_chinese_name             :string
#
# Indexes
#
#  index_train_templates_on_creator_id              (creator_id)
#  index_train_templates_on_exam_template_id        (exam_template_id)
#  index_train_templates_on_train_template_type_id  (train_template_type_id)
#

#

class TrainTemplate < ApplicationRecord
  include TrainTemplateValidators
  has_many :trains
  has_many :online_materials, as: :attachable , dependent: :destroy
  has_many :attend_attachments, as: :attachable
  belongs_to :train_template_type
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :exam_template, class_name: 'QuestionnaireTemplate', foreign_key: 'exam_template_id'
  validates :chinese_name, :english_name, :simple_chinese_name, :course_number, :teaching_form, :train_template_type_id, :training_credits, :online_or_offline_training, :limit_number, :course_total_time, :course_total_count, :trainer, :assessment_method, presence: true
  validates_with AssessmentMethodWithRightExamFormatAndExamTemplateIdValidator
  enum online_or_offline_training: {online_training: 0, offline_training: 1}
  enum assessment_method: {by_attendance_rate: 0, by_test_scores:1, by_both: 2}
  enum exam_format: {online: 0, offline: 1}
  scope :by_order, lambda{|sort_column, sort_direction|
     if sort_column == :course_name
       order(select_language => sort_direction)
     elsif sort_column == :creator_name
       order("users.#{select_language.to_s} #{sort_direction.to_s}")
     else
       order(sort_column => sort_direction)
     end
  }

  scope :joins_train_template_type_and_creator, lambda{
    joins(:train_template_type, :creator)
  }
  scope :by_course_number, lambda{|course_number|
    where(course_number: course_number) if course_number
  }
  scope :by_course_name, lambda{|course_name|
    where(select_language => course_name) if course_name
  }
  scope :by_train_template_type_id, lambda{|id|
    where(train_template_type_id: id) if id
  }
  scope :by_training_credits, lambda{ |train_credits|
    where(training_credits: train_credits) if train_credits
  }
  scope :by_exam_format, lambda{|exam_format|
    where(exam_format: exam_format) if exam_format
  }
  scope :by_creator_name, lambda {|creator_name|
    where(users:{select_language => creator_name}) if creator_name
  }

  scope :by_assessment_method, lambda{|assessment_method|
    where(assessment_method: assessment_method) if assessment_method
  }

  scope :by_updated_at, lambda{|updated_at_begin, updated_at_end|
   if updated_at_begin && updated_at_end
     where(train_templates: {updated_at: updated_at_begin...updated_at_end})
   elsif updated_at_begin
     where('train_templates.updated_at > :updated_at_begin', updated_at_begin: updated_at_begin)
   elsif updated_at_end
     where('train_templates.updated_at < :updated_at_end', updated_at_end: updated_at_end)
   end
  }

  def self.create_with_params(template, materials_params, attachments_params, exam_template_id, fill_in_the_blank_questions_params, choice_questions_params, matrix_single_choice_questions_params)
    train_template = nil
    ActiveRecord::Base.transaction do
      # Self Model
      train_template = self.create(template)
      # OnlineMaterials Associations
      materials_params.each do |item_params|
        train_template.online_materials.create(item_params)
      end if materials_params
      # AttendAttachments Associations
      attachments_params.each do |item_params|
        train_template.attend_attachments.create(item_params)
      end if attachments_params
      if exam_template_id
        questionnaire_template = QuestionnaireTemplate.find(exam_template_id)
        train_template.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        train_template.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        train_template.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        qt = QuestionnaireTemplate.create_with_params(
          exam_template_id,
          fill_in_the_blank_questions_params,
          choice_questions_params,
          matrix_single_choice_questions_params,
          "train_template"
        )
      end
      train_template.exam_template_id = qt.id if qt
      train_template.save!
    end
    train_template.try(:id)
  end

  def update_with_params(template, online_create, attend_create, fill_in_the_blank_questions_params, choice_questions_params, matrix_single_choice_questions_params)
    result = nil
    ActiveRecord::Base.transaction do
      # Self Model
      self.update(template.except(:exam_template_id))
      # OnlineMaterials Associations
      self.online_materials.destroy_all  unless  online_create.nil? || online_create.empty?
      online_create.each do |item_params|
        self.online_materials.create(item_params)
      end if online_create
      self.attend_attachments.destroy_all  unless  attend_create.nil? ||  attend_create.empty?
      attend_create.each do |item_params|
        self.attend_attachments.create(item_params)
      end if attend_create
      if template[:exam_template_id]
        questionnaire_template = QuestionnaireTemplate.find(template[:exam_template_id])
        self.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        self.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        self.questionnaire_template_chinese_name = questionnaire_template.chinese_name
        qt = QuestionnaireTemplate.create_with_params(
            template[:exam_template_id],
            fill_in_the_blank_questions_params,
            choice_questions_params,
            matrix_single_choice_questions_params,
            "train_template"
        )
        self.exam_template.destroy if self.exam_template
        self.exam_template_id = qt.id
      end
      self.save

      result = self.id
    end
    result
  end

  def self.field_options
    query = self.joins_train_template_type_and_creator
    train_template_type = query.select(:train_template_type_id).distinct.map{|item|TrainTemplateType.find(item[:train_template_type_id].as_json) }
    assessment_method = Config.get_option_from_selects('assessment_method', query.select(:assessment_method).map{|item| item['assessment_method']}.try(:uniq))
    questionnaire_templates = QuestionnaireTemplate.all.as_json
    {
        train_template_type: train_template_type,
        assessment_method: assessment_method,
        questionnaire_templates: questionnaire_templates
    }
  end

  def self.create_params
    super - %w(creator_id)
  end


end
