class CreateAttendanceItems < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_items do |t|

      t.belongs_to :user
      t.belongs_to :position
      t.belongs_to :department
      t.belongs_to :attendance
      t.belongs_to :shift

      t.datetime :attendance_date
      t.datetime :start_working_time
      t.datetime :end_working_time
      t.text :comment

      t.string :region

      t.timestamps
    end

    add_index :attendance_items, :attendance_date
  end
end
