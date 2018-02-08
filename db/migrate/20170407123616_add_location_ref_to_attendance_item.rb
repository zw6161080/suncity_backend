class AddLocationRefToAttendanceItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :attendance_items, :location, foreign_key: true
    add_column :attendance_items, :updated_states_from, :string
  end
end
