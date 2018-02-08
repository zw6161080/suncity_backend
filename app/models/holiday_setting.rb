# == Schema Information
#
# Table name: holiday_settings
#
#  id                  :integer          not null, primary key
#  region              :string
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  category            :integer
#  holiday_date        :date
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class HolidaySetting < ApplicationRecord
  enum category: { force_holiday: 0, public_holiday: 1 }

  has_many :force_holiday_working_records, dependent: :destroy

  after_save :create_record_by_single_force_holiday
  after_destroy :clear_force_holiday_working_records

  def create_record_by_single_force_holiday
    if self.category == 'force_holiday'
      attends = Attend.joins(:roster_object => :class_setting)
                    .where(attend_date: self.holiday_date)
                    .where.not(roster_object_id: nil)
                    .where.not(:roster_objects => { class_setting_id: nil })
      attends.each do |attend|
        ForceHolidayWorkingRecord.find_or_create_by(
            user_id: attend.user_id,
            holiday_setting_id: self.id,
            attend_id: attend.id
        )
      end
    end
  end

  def clear_force_holiday_working_records
    self.force_holiday_working_records.destroy_all
  end

end
