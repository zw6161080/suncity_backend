class AddColumnsToAdjustRosterRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :adjust_roster_records, :special_approver, :string
  end
end
