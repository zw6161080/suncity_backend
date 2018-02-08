class ChangeColumnsToTransferPositionApplyByEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :transfer_position_apply_by_employees, :creator_id, :integer
    add_column :transfer_position_apply_by_employees, :job_transfer_id, :integer
    rename_column :transfer_position_apply_by_employees, :salary_template, :salary_record
    rename_column :transfer_position_apply_by_employees, :new_salary_template, :new_salary_record
    rename_column :transfer_position_apply_by_employees, :welfare_template, :welfare_record
    rename_column :transfer_position_apply_by_employees, :new_welfare_template, :new_welfare_record
  end
end
