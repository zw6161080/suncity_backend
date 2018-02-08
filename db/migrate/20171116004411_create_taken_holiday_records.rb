class CreateTakenHolidayRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :taken_holiday_records do |t|
      t.references :user, foreign_key: true, index: true
      t.references :holiday_record, foreign_key: true, index: true
      t.date :taken_holiday_date
      t.timestamps
    end
  end
end
