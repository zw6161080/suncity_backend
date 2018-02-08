class AddSalaryTemplateToTransferPositionApplyByDepartment < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_departments, :salary_template, :jsonb
    add_column :transfer_position_apply_by_departments, :new_salary_template, :jsonb
    add_column :transfer_position_apply_by_departments, :welfare_template, :jsonb
    add_column :transfer_position_apply_by_departments, :new_welfare_template, :jsonb
  end
end
