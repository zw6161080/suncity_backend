class CreateHolidayRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_records do |t|
      t.string :region
      t.integer :user_id

      t.boolean :is_compensate

      t.integer :holiday_type

      t.date :start_date
      t.datetime :start_time
      t.date :end_date
      t.datetime :end_time

      t.integer :days_count
      t.integer :hours_count

      t.integer :year

      t.boolean :is_deleted

      t.text :comment

      t.integer :creator_id

      t.timestamps
    end
  end
end
