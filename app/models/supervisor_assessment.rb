# == Schema Information
#
# Table name: supervisor_assessments
#
#  id                :integer          not null, primary key
#  region            :string
#  user_id           :integer
#  employment_status :integer
#  exam_mode         :integer
#  training_result   :integer
#  attendance_rate   :integer
#  score             :integer
#  assessment_status :integer
#  filled_in_date    :date
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  train_id          :integer
#
# Indexes
#
#  index_supervisor_assessments_on_user_id  (user_id)
#

class SupervisorAssessment < ApplicationRecord
  belongs_to :user

  has_one :attend_questionnaire_template, as: :attachable
  has_one :attend_questionnaire, as: :attachable

  has_one :questionnaire, through: :attend_questionnaire
  has_one :questionnaire_template, through: :attend_questionnaire_template

  enum employment_status: { in_service: 0, dimission: 1 }
  enum exam_mode: { online: 0, offline: 1 }
  enum training_result: { pass: 0, fail: 1 }
  enum assessment_status: { filled_in: 0, unfilled: 1 }

  scope :by_empoid, lambda { |empoid|
    if empoid
      user_ids = User.where("empoid like ?", "%#{empoid}%")
      where(user_id: user_ids)
    end
  }

  scope :by_user_name, lambda { |user_name, lang|
    if user_name
      user_ids = User.where("#{lang} like ?", "%#{user_name}%")
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

  scope :by_exam_mode, lambda { |exam_mode|
    where(exam_mode: exam_mode) if exam_mode
  }

  scope :by_training_result, lambda { |training_result|
    where(training_result: training_result) if training_result
  }

  scope :by_assessment_status, lambda { |assessment_status|
    where(assessment_status: assessment_status) if assessment_status
  }

  scope :by_score, lambda { |score|
    where(score: score) if score
  }

  scope :by_attendance_rate, lambda { |attendance_rate|
    where(attendance_rate: attendance_rate) if attendance_rate
  }

  scope :by_filled_in_date, lambda { |filled_in_date|
    where(filled_in_date: filled_in_date) if filled_in_date
  }

  def self.create_supervisor_assessment_by_train(train, questionnaire_template_id, current_user)
    result = false

    department_group_users = Role.find_by(key: 'department_group')&.users

    ActiveRecord::Base.transaction do
      qt = QuestionnaireTemplate.find(questionnaire_template_id)
      train.final_lists&.each do |item|
        sa = SupervisorAssessment.create(region: item.user.profile.region, user_id: item.user_id, train_id: train.id, assessment_status: 1)

        sa.exam_mode = train.exam_format == 'online' ? 0 : 1

        tp = TrainingPaper.where(train_id: train.id, user_id: item.user_id).first
        if tp
          sa.score = tp.score
        end

        user = User.find(item.user_id)
        sa.attendance_rate = TrainingService.calcul_attend_percentage(train, user).truncate(2).to_s("F").to_f*100

        sa.employment_status = ProfileService.is_leave?(user) ? 1 : 0

        sa.training_result = item.train_result == 'train_pass' ? 0 : 1
        sa.save

        q = Questionnaire.create_with_template(item.user_id, qt)

        q.release_user_id = current_user.id
        q.release_date = Time.zone.now.to_date
        q.save

        # q = Questionnaire.create!(user_id: item.user_id, questionnaire_template_id: qt.id)
        # q.fill_in_the_blank_questions << qt.fill_in_the_blank_questions
        # q.choice_questions << qt.choice_questions
        # q.matrix_single_choice_questions << qt.matrix_single_choice_questions

        sa.create_attend_questionnaire(questionnaire_id: q.id)
        sa.create_attend_questionnaire_template!(questionnaire_template_id: qt.id)



        department = item.user&.department.id
        if department

          department_head_ids = department_group_users&.where(department_id: department)&.pluck(:id)
          Message.add_notification(train,
                                   'supervisor_assessment',
                                   department_head_ids,
                                   {chinese_name: item.user.chinese_name, english_name: item.user.english_name, simple_chinese_name: item.user.simple_chinese_name, supervisor_assessment: sa.slice(:id)}) unless (department_head_ids.nil? || department_head_ids.empty?)
          # Message.add_notification(train, 'supervisor_assessment', Role.find(9).users.where(department_id: department).ids, {chinese_name: item.user.chinese_name, english_name: item.user.english_name, simple_chinese_name: item.user.simple_chinese_name, supervisor_assessment: sa.slice(:id)})
        end
      end

      result = true
    end
    result
  end

  scope :by_train, lambda { |train_id|
    where(train_id: train_id) if train_id
  }
end
