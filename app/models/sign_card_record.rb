# == Schema Information
#
# Table name: sign_card_records
#
#  id                   :integer          not null, primary key
#  region               :string
#  user_id              :integer
#  is_compensate        :boolean
#  is_get_to_work       :boolean
#  sign_card_date       :date
#  sign_card_time       :datetime
#  sign_card_setting_id :integer
#  sign_card_reason_id  :integer
#  comment              :text
#  is_deleted           :boolean
#  creator_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  source_id            :integer
#  is_next              :boolean          default(FALSE)
#  input_date           :date
#  input_time           :string
#
# Indexes
#
#  index_sign_card_records_on_creator_id  (creator_id)
#  index_sign_card_records_on_user_id     (user_id)
#

class SignCardRecord < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :sign_card_record_histories, -> { order "updated_at DESC" }, class_name: 'SignCardRecord', foreign_key: 'source_id'

  has_one :sign_card_setting
  has_one :sign_card_reason

  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy

  # def date_of_employment
  #   user = User.find(self.user_id)
  #   user.date_of_employment
  # end

  def sign_card_setting_detail
    self.sign_card_setting_id ? SignCardSetting.find(self.sign_card_setting_id) : nil
  end

  def sign_card_reason_detail
    self.sign_card_reason_id ? SignCardReason.find(self.sign_card_reason_id) : nil
  end

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

  scope :by_user, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_sign_card_reason_id, lambda { |sign_card_reason_id|
    where(sign_card_reason_id: sign_card_reason_id) if sign_card_reason_id
  }

  scope :by_sign_card_date, lambda { |start_date, end_date|
    if start_date && end_date
      where(sign_card_date: start_date .. end_date)
    elsif start_date && !end_date
      where("sign_card_date > ?", start_date)
    elsif !start_date && end_date
      where("sign_card_date < ?", end_date)
    end
  }

  scope :by_is_deleted, lambda { |is_deleted|
    unless (is_deleted == 'true' || is_deleted == true)
      where(is_deleted: false).or(where(is_deleted: nil))
    end
  }

  def self.deal_with_compensation(start_d, end_d, result)
    records = SignCardRecord.where(sign_card_date: start_d .. end_d, is_compensate: true)

    records.each do |r|
      r.is_compensate = result
      AttendMonthlyReport.update_calc_status(r.user_id, r.sign_card_date)
      AttendAnnualReport.update_calc_status(r.user_id, r.sign_card_date)
      r.save!
    end
  end

  def self.destroy_punching_card_on_holiday_exception(attend)
    if attend.on_work_time == nil && attend.off_work_time == nil && attend.attend_states.where(auto_state: 'punching_card_on_holiday_exception').count > 0
      attend.attend_states.where(auto_state: 'punching_card_on_holiday_exception').each do |state|
        state.destroy
      end
    end
  end

  def self.create_punching_card_on_holiday_exception(record)
    d = record.sign_card_date.to_date
    att = Attend.find_attend_by_user_and_date(record.user_id, d)
    hrs = HolidayRecord.where(source_id: nil, is_deleted: [false, nil], user_id: record.user_id)
            .where("start_date <= ? AND end_date >= ?", d, d)
    otr = OvertimeRecord.where(source_id: nil, is_deleted: [false, nil], user_id: record.user_id)
            .where("overtime_start_date <= ? AND overtime_end_date >= ?", d, d)

    user = User.find_by(id: record.user_id)
    can_punch = user && user.punch_card_state_of_date(att&.attend_date)

    if hrs.count > 0 && otr.count <= 0 && att.attend_states.where(auto_state: 'punching_card_on_holiday_exception').count <= 0
      att.attend_states.create(auto_state: 'punching_card_on_holiday_exception') if can_punch
    end
  end

end
