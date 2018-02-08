class RenameColumnToWelfareTemplates < ActiveRecord::Migration[5.0]
  def change
    rename_column :welfare_templates, :reduce_salary_for_leave, :reduce_salary_for_sick
  end
end
