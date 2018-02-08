class AddOvertimeCountToAttendanceItem < ActiveRecord::Migration[5.0]
  def change
    add_column :attendance_items, :overtime_count, :integer
  end
end
