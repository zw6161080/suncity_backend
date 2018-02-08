class AddChangeToPublicHolidayCountToHolidayRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :holiday_records, :change_to_general_holiday_count, :integer
  end
end
