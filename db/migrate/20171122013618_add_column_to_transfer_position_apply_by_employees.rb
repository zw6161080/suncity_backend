class AddColumnToTransferPositionApplyByEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_employees, :salary_calculation, :string
  end
end
