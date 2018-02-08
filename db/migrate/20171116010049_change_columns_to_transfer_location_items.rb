class ChangeColumnsToTransferLocationItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :transfer_location_items, :salary_template_type, :salary_calculation
  end
end
