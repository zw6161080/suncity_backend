class RemoveDateRangeAndWdayFromShiftEmployeeCountSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :shift_employee_count_settings, :date_range,  :daterange
    remove_column :shift_employee_count_settings, :wday, :integer
  end
end
