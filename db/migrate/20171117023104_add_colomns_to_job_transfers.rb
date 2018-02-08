class AddColomnsToJobTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :job_transfers, :transferable_id, :integer
    add_column :job_transfers, :transferable_type, :string
    add_index :job_transfers, [:transferable_id, :transferable_type]
  end
end
