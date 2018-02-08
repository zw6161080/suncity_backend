class AddRosterIdToShiftsAndShiftGroups < ActiveRecord::Migration[5.0]
  def change
    add_reference :shifts, :roster, index: true
    add_reference :shift_groups, :roster, index: true
  end
end
