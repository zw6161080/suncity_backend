class RemoveDepartmentIdFromShiftsAndShiftGroups < ActiveRecord::Migration[5.0]
  def change
    remove_column :shifts, :department_id
    remove_column :shift_groups, :department_id
  end
end
