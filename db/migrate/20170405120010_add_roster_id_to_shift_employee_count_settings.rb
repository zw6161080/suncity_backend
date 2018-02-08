class AddRosterIdToShiftEmployeeCountSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :shift_employee_count_settings, :roster_id, :integer

    add_index :shift_employee_count_settings, :roster_id
  end
end
