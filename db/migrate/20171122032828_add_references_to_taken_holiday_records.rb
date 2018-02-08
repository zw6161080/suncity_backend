class AddReferencesToTakenHolidayRecords < ActiveRecord::Migration[5.0]
  def change
    add_reference :taken_holiday_records, :attend, foreign_key: true, index: true

    change_column :taken_holiday_records, :taken_holiday_date, :datetime
  end
end
