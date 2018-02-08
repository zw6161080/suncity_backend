class AddLeaveTypeToRosterItems < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_items, :leave_type, :string
  end
end
