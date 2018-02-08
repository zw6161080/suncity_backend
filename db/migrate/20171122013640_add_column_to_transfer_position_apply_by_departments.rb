class AddColumnToTransferPositionApplyByDepartments < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_departments, :salary_calculation, :string
  end
end
