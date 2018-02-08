# == Schema Information
#
# Table name: dimission_appointments
#
#  id                        :integer          not null, primary key
#  region                    :string
#  user_id                   :integer
#  status                    :integer
#  questionnaire_template_id :integer
#  questionnaire_id          :integer
#  last_working_date         :date
#  duration                  :string
#  had_transfer              :boolean
#  last_transfer_date        :date
#  appointment_date          :date
#  appointment_time          :string
#  appointment_location      :string
#  appointment_description   :text
#  opinion                   :text
#  other_opinion             :text
#  summary                   :text
#  inputter_id               :integer
#  input_date                :date
#  comment                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_dimission_appointments_on_inputter_id  (inputter_id)
#  index_dimission_appointments_on_user_id      (user_id)
#

class DimissionAppointment < ApplicationRecord
  belongs_to :user
  belongs_to :inputter, :class_name => "User", :foreign_key => "inputter_id"

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy
  has_one :questionnaire_template
  has_one :questionnaire

  enum status: { have_not_started: 0, wait_for_filling_in_the_questionnaire: 1,
                 wait_for_making_the_appointment: 2, finished: 3 }

  scope :by_employee_name, lambda { |employee_name, lang|
    if employee_name
      employee_ids = User.where("#{lang} like ?", "%#{employee_name}%")
      where(user_id: employee_ids)
    end
  }

  scope :by_empoid, lambda { |empoid|
    if empoid
      user_ids = User.where("empoid like ?", "%#{empoid}%")
      where(user_id: user_ids)
    end
  }

  scope :by_inputter_name, lambda { |inputter_name, lang|
    if inputter_name
      inputter_ids = User.where("#{lang} like ?", "%#{inputter_name}%")
      where(inputter_id: inputter_ids)
    end
  }

  scope :by_input_date, lambda { |input_date|
    where('input_date like ?', "%#{input_date}%") if input_date
  }

  scope :by_status_type, lambda { |status|
    where(status: status) if status
  }

  scope :by_template_id, lambda { |template_id|
    where(questionnaire_template_id: template_id) if template_id
  }

  scope :by_appointment_time, lambda { |time|
    where(appointment_time: time) if time
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

  scope :by_appointment_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(appointment_date: start_date .. end_date)
    elsif start_date && !end_date
      where("appointment_date > ?", start_date)
    elsif !start_date && end_date
      where("appointment_date < ?", end_date)
    end
  }

  scope :by_last_working_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(last_working_date: start_date .. end_date)
    elsif start_date && !end_date
      where("last_working_date > ?", start_date)
    elsif !start_date && end_date
      where("last_working_date < ?", end_date)
    end
  }

  def self.detail_by_id(id)
    DimissionAppointment
      .includes({user: [:location, :department, :position]},
                approval_items: [:user],
                attend_attachments: [:user, :attachment])
      .find(id)
  end
end
