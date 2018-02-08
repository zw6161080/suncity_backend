# == Schema Information
#
# Table name: training_papers
#
#  id                 :integer          not null, primary key
#  region             :string
#  user_id            :integer
#  employment_status  :integer
#  exam_mode          :integer
#  score              :integer
#  attendance_rate    :integer
#  paper_status       :integer
#  correct_percentage :integer
#  filled_in_date     :date
#  latest_upload_date :date
#  comment            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  train_id           :integer
#
# Indexes
#
#  index_training_papers_on_train_id  (train_id)
#  index_training_papers_on_user_id   (user_id)
#

class TrainingPaper < ApplicationRecord
  belongs_to :user
  belongs_to :train
  has_many :attend_attachments, as: :attachable, dependent: :destroy

  has_one :attend_questionnaire_template, as: :attachable
  has_one :attend_questionnaire, as: :attachable

  has_one :questionnaire, through: :attend_questionnaire
  has_one :questionnaire_template, through: :attend_questionnaire_template

  enum employment_status: { in_service: 0, dimission: 1 }
  enum exam_mode: { online: 0, offline: 1 }
  enum paper_status: { filled_in: 0, unfilled: 1 }

  def self.create_papers_by_train(train, current_user)
    result = false
    ActiveRecord::Base.transaction do
      qt = QuestionnaireTemplate.find(train.exam_template_id) if train.exam_template_id
      train.final_lists&.each do|item|
        tp = TrainingPaper.create(region: item.user.profile.region, user_id: item.user_id, train_id: train.id, paper_status: 1)
        tp.exam_mode = train.exam_format == 'online' ? 0 : 1
        user = User.find(item.user_id)

        tp.employment_status = ProfileService.is_leave?(user) ? 1 : 0

        tp.attendance_rate = TrainingService.calcul_attend_percentage(train, user).truncate(2).to_s("F").to_f*100
        tp.save

        if train.exam_format == 'online'
          q = Questionnaire.create_with_template(item.user_id, qt)
          q.release_user_id = current_user.id
          q.release_date = Time.zone.now.to_date
          q.save

          # q = Questionnaire.create!(user_id: item.user_id, questionnaire_template_id: qt.id)
          # q.fill_in_the_blank_questions << qt.fill_in_the_blank_questions
          # q.choice_questions << qt.choice_questions
          # q.matrix_single_choice_questions << qt.matrix_single_choice_questions

          tp.create_attend_questionnaire(questionnaire_id: q.id)
          tp.create_attend_questionnaire_template!(questionnaire_template_id: qt.id) if qt

          Message.add_notification(train, 'test', [item.user_id], {training_paper: tp.slice(:id)}) if item.user_id
          # Message.add_notification(train, 'test', train.final_lists&.pluck(:user_id), {training_paper: tp.slice(:id)})
        end
      end
      result = true
    end
    result
  end


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

  scope :by_paper_status, lambda { |paper_status|
    where(paper_status: paper_status) if paper_status
  }

  scope :by_score, lambda { |score|
    where(score: score) if score
  }

  scope :by_attendance_rate, lambda { |attendance_rate|
    where(attendance_rate: attendance_rate) if attendance_rate
  }

  scope :by_correct_percentage, lambda { |correct_percentage|
    where(correct_percentage: correct_percentage) if correct_percentage
  }

  scope :by_filled_in_date, lambda { |filled_in_date|
    where(filled_in_date: filled_in_date) if filled_in_date
  }

  scope :by_latest_upload_date, lambda { |latest_upload_date|
    where(latest_upload_date: latest_upload_date) if latest_upload_date
  }

  scope :by_train, lambda { |train_id|
    where(train_id: train_id) if train_id
  }
end
