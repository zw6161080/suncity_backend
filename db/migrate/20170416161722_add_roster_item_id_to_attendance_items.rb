class AddRosterItemIdToAttendanceItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :attendance_items, :roster_item, foreign_key: true
  end
end
