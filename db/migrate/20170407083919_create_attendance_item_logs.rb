class CreateAttendanceItemLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_item_logs do |t|
      t.belongs_to :attendance_item
      t.belongs_to :user
      t.datetime :log_time
      t.string :log_type
      t.integer :log_type_id

      t.timestamps
    end
  end
end
