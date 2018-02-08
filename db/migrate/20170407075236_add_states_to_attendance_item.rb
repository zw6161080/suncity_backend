class AddStatesToAttendanceItem < ActiveRecord::Migration[5.0]
  def change
    add_column :attendance_items, :states, :string, default: ""
  end
end
