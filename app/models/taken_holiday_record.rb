# == Schema Information
#
# Table name: taken_holiday_records
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  holiday_record_id  :integer
#  taken_holiday_date :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  attend_id          :integer
#
# Indexes
#
#  index_taken_holiday_records_on_attend_id          (attend_id)
#  index_taken_holiday_records_on_holiday_record_id  (holiday_record_id)
#  index_taken_holiday_records_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_30a4d4bd4a  (holiday_record_id => holiday_records.id)
#  fk_rails_bfc14cddb1  (attend_id => attends.id)
#  fk_rails_c139376fe4  (user_id => users.id)
#

class TakenHolidayRecord < ApplicationRecord

  include StatementAble

  belongs_to :user
  belongs_to :holiday_record
  belongs_to :attend

  def self.create_taken_holiday_record(holiday_record)
    begin_date = Time.zone.at(holiday_record.start_date.to_time).to_datetime
    end_date = Time.zone.at(holiday_record.end_date.to_time).to_datetime
    (begin_date.to_i .. end_date.to_i).step(1.day) do |date|
      day = Time.zone.at(date)
      if day < Time.zone.now
        attend = Attend.find_by(attend_date: day, user_id: holiday_record.user_id)
        taken_record = TakenHolidayRecord.find_or_create_by(
            taken_holiday_date: day,
            user_id: holiday_record.user_id,
            holiday_record_id: holiday_record.id)
        taken_record.update(attend_id: attend.id) if attend
      end
    end
  end

  def self.generate_taken_holiday_records
    HolidayRecord.where(source_id: nil).where(is_deleted: [false, nil]).each do |record|
      # Time.zone.at(Date.current.to_time).to_datetime
      begin_date = Time.zone.at(record.start_date.to_time).to_datetime
      end_date = Time.zone.at(record.end_date.to_time).to_datetime
      (begin_date.to_i .. end_date.to_i).step(1.day) do |date|
        day = Time.zone.at(date)
        if day < Time.zone.now
          attend = Attend.find_by(attend_date: day, user_id: record.user_id)
          taken_record = TakenHolidayRecord.find_or_create_by(
              taken_holiday_date: day,
              user_id: record.user_id,
              holiday_record_id: record.id)
          taken_record.update(attend_id: attend.id) if attend
        end
      end
    end
  end


  scope :by_name, ->(name) {
    where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_user_id, ->(user_ids) {
    where(user_id: user_ids)
  }

    def self.extra_query_params
      # 在Model中Override該方法，提供需要額外支持的搜索參數, eg:
      # [ { key: 'day_example', search_type: 'day_range' }, { key: 'value_example' } ]
      [{ key: 'user_id', search_type: 'screen' }]
    end

  class << self

    def department_options
      Department.where(id: self.joins(:user).select('users.department_id'))
    end

    def position_options
      Position.where(id: self.joins(:user).select('users.position_id'))
    end
  end

end
