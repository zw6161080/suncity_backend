class AddPlanStartTimeAndPlanEndTimeToAttendanceItems < ActiveRecord::Migration[5.0]
  def change
    add_column :attendance_items, :plan_start_time, :datetime
    add_column :attendance_items, :plan_end_time, :datetime
  end
end
