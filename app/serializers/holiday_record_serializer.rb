class HolidayRecordSerializer < ActiveModel::Serializer
  attributes *HolidayRecord.column_names,
             :holiday_name

  belongs_to :user
  belongs_to :creator
  has_many :holiday_record_histories

  def holiday_name
    return ReservedHolidaySetting.find(object.reserved_holiday_setting_id) if object.reserved_holiday_setting_id
    HolidayRecord.holiday_type_table.select { |op| op[:key] == object.holiday_type }.first
  end

end
