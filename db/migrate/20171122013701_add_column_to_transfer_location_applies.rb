class AddColumnToTransferLocationApplies < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_location_applies, :salary_calculation, :string
  end
end
