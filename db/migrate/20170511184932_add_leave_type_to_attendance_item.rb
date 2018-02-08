class AddLeaveTypeToAttendanceItem < ActiveRecord::Migration[5.0]
  def change
    add_column :attendance_items, :leave_type, :string
  end
end
