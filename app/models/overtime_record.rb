# == Schema Information
#
# Table name: overtime_records
#
#  id                               :integer          not null, primary key
#  region                           :string
#  user_id                          :integer
#  is_compensate                    :boolean
#  overtime_type                    :integer
#  compensate_type                  :integer
#  overtime_start_date              :date
#  overtime_end_date                :date
#  overtime_start_time              :datetime
#  overtime_end_time                :datetime
#  overtime_hours                   :integer
#  vehicle_department_over_time_min :integer
#  comment                          :text
#  is_deleted                       :boolean
#  creator_id                       :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  source_id                        :integer
#  overtime_true_start_date         :date
#  input_date                       :date
#  input_time                       :string
#
# Indexes
#
#  index_overtime_records_on_creator_id  (creator_id)
#  index_overtime_records_on_user_id     (user_id)
#

class OvertimeRecord < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :overtime_record_histories, -> { order "updated_at DESC" }, class_name: 'OvertimeRecord', foreign_key: 'source_id'

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy

  enum overtime_type: { weekdays: 0, general_holiday: 1, force_holiday: 2, public_holiday: 3, vehicle_department: 4 }
  enum compensate_type: { money: 0, holiday: 1 }

  scope :by_company_name, lambda { |company_name|
    joins(:user).where(users: { company_name: company_name }) if company_name
  }

  scope :by_location_id, lambda { |location_id|
    if location_id
      joins(:user).where(users: { location_id: location_id})
    end
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

  scope :by_user, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_overtime_date, lambda { |start_date, end_date|
    if start_date && end_date
      where("overtime_start_date >= ? AND overtime_end_date <= ?", start_date, end_date)
    elsif start_date && !end_date
      where("overtime_start_date >= ?", start_date)
    elsif !start_date && end_date
      where("overtime_end_date <= ?", end_date)
    end
  }

  scope :by_is_deleted, lambda { |is_deleted|
    unless is_deleted == 'true' || is_deleted == true
      where(is_deleted: [false, nil])
    end
  }

  scope :by_overtime_type, lambda { |overtime_type|
    where(overtime_type: overtime_type) if overtime_type
  }

  scope :by_compensate_type, lambda { |compensate_type|
    where(compensate_type: compensate_type) if compensate_type
  }

  def self.deal_with_compensation(start_d, end_d, result)
    records = OvertimeRecord.where(overtime_start_date: start_d .. end_d, is_compensate: true)

    records.each do |r|
      r.is_compensate = result
      AttendMonthlyReport.update_calc_status(r.user_id, r.overtime_start_date)
      AttendAnnualReport.update_calc_status(r.user_id, r.overtime_start_date)
      r.save!
    end
  end

  def self.destroy_punching_card_on_holiday_exception(attend)
    if attend.attend_states.where(auto_state: 'punching_card_on_holiday_exception').count > 0
      attend.attend_states.where(auto_state: 'punching_card_on_holiday_exception').each do |state|
        state.destroy
      end
    end
  end

  def self.create_punching_card_on_holiday_exception(overtime_record)
    (overtime_record.overtime_start_date .. overtime_record.overtime_end_date).each do |d|
      att = Attend.find_attend_by_user_and_date(overtime_record.user_id, d)
      hrs = HolidayRecord.where(source_id: nil, is_deleted: [false, nil], user_id: overtime_record.user_id)
              .where("start_date <= ? AND end_date >= ?", d, d)
      scr = SignCardRecord.where(source_id: nil, is_deleted: [false, nil], user_id: overtime_record.user_id, sign_card_date: d)

      user = User.find_by(id: att&.user_id)
      can_punch = user && user.punch_card_state_of_date(att&.attend_date)

      if (att.on_work_time != nil || att.off_work_time != nil || scr.count > 0) && hrs.count > 0
        att.attend_states.create(auto_state: 'punching_card_on_holiday_exception') if can_punch
      end
    end
  end

end
