class AddSnapshotEmployesCountToRosters < ActiveRecord::Migration[5.0]
  def change
    add_column :rosters, :snapshot_employees_count, :integer
  end
end
