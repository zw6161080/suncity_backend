class AddAvailabilityToTimesheets < ActiveRecord::Migration[5.0]
  def change
    add_column :timesheets, :roster_id,  :integer
    add_index :timesheets, :roster_id
  end
end
