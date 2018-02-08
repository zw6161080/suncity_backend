class ChangeColumnsToTransferLocationApplies < ActiveRecord::Migration[5.0]
  def change
    remove_column :transfer_location_applies, :creator_id, :integer
    add_column :transfer_location_applies, :job_transfer_id, :integer
  end
end
