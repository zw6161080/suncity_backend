class ChangeReferenceToForceHolidayWorkingRecords < ActiveRecord::Migration[5.0]
  def change
    add_reference :force_holiday_working_records, :attend, index: true, foreign_key: true
  end
end
