class AddInputDateToHolidayRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :holiday_records, :input_date, :date
    add_column :holiday_records, :input_time, :string
  end
end
