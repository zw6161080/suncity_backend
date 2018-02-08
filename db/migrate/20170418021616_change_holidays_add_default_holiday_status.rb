class ChangeHolidaysAddDefaultHolidayStatus < ActiveRecord::Migration[5.0]
  change_table :holidays do |t|
    t.change :status, :integer, null: false, default: 1
  end
end
