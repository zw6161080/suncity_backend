class AddIsModifiedToAttendanceItem < ActiveRecord::Migration[5.0]
  def change
    add_column :attendance_items, :is_modified, :boolean
  end
end
