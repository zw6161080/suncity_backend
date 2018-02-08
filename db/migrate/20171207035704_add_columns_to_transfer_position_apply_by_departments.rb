class AddColumnsToTransferPositionApplyByDepartments < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_departments, :apply_group_id, :integer
    add_column :transfer_position_apply_by_departments, :transfer_group_id, :integer
  end
end
