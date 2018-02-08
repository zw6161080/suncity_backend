class CreateReviseClockItems < ActiveRecord::Migration[5.0]
  def change
    create_table :revise_clock_items do |t|
      t.belongs_to :revise_clock
      t.date :clock_date
      t.datetime :clock_in_time
      t.datetime :clock_out_time
      t.jsonb :attendance_state
      t.datetime :new_clock_in_time
      t.datetime :new_clock_out_time
      t.jsonb :new_attendance_state
      t.text :comment

      t.timestamps
    end
  end
end
