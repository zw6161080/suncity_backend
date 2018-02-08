class CreateForceHolidayWorkingRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :force_holiday_working_records do |t|
      t.references :user, foreign_key: true, index: true
      t.references :holiday_setting, foreign_key: true, index: true
      t.timestamps
    end
  end
end
