class AddReservedHolidaySettingIdToHolidayRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :holiday_records, :reserved_holiday_setting_id, :integer
  end
end
