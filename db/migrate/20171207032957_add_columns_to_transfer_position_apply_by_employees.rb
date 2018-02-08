class AddColumnsToTransferPositionApplyByEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_employees, :apply_group_id, :integer
    add_column :transfer_position_apply_by_employees, :transfer_group_id, :integer
  end
end
