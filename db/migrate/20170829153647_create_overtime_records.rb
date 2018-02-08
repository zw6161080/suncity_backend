class CreateOvertimeRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :overtime_records do |t|
      t.string :region
      t.integer :user_id

      t.boolean :is_compensate
      t.integer :overtime_type
      t.integer :compensate_type

      t.date :overtime_start_date
      t.date :overtime_end_date

      t.datetime :overtime_start_time
      t.datetime :overtime_end_time

      t.integer :overtime_hours
      t.integer :vehicle_department_over_time_min

      t.text :comment

      t.boolean :is_deleted

      t.integer :creator_id

      t.timestamps
    end
  end
end
