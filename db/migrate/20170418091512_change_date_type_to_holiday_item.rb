class ChangeDateTypeToHolidayItem < ActiveRecord::Migration[5.0]
  change_table :holiday_items do |t|
    t.change :start_time, :date
    t.change :end_time, :date
  end
end
