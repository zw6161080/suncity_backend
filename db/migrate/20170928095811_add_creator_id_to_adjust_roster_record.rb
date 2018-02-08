class AddCreatorIdToAdjustRosterRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :adjust_roster_records, :creator_id, :integer
  end
end
