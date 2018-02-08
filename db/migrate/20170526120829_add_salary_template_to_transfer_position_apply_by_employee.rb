class AddSalaryTemplateToTransferPositionApplyByEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :transfer_position_apply_by_employees, :salary_template, :jsonb
    add_column :transfer_position_apply_by_employees, :new_salary_template, :jsonb
    add_column :transfer_position_apply_by_employees, :welfare_template, :jsonb
    add_column :transfer_position_apply_by_employees, :new_welfare_template, :jsonb
  end
end
