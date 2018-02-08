class AddColumnsToJobTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :job_transfers, :new_group_id, :integer
    add_column :job_transfers, :original_group_id, :integer
  end
end
