class ChangeColumnsToTransferPositionApplyByDepartments < ActiveRecord::Migration[5.0]
  def change
    remove_column :transfer_position_apply_by_departments, :creator_id, :integer
    add_column :transfer_position_apply_by_departments, :job_transfer_id, :integer
    rename_column :transfer_position_apply_by_departments, :salary_template, :salary_record
    rename_column :transfer_position_apply_by_departments, :new_salary_template, :new_salary_record
    rename_column :transfer_position_apply_by_departments, :welfare_template, :welfare_record
    rename_column :transfer_position_apply_by_departments, :new_welfare_template, :new_welfare_record
  end
end
