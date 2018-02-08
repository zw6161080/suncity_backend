class ChangeColumnsToLentTemporarilyItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :lent_temporarily_items, :lent_salary_template_type, :lent_salary_calculation
    rename_column :lent_temporarily_items, :return_salary_template_type, :return_salary_calculation
    remove_column :lent_temporarily_items, :lent_salary_template, :string
    remove_column :lent_temporarily_items, :return_salary_template, :string
    remove_column :lent_temporarily_items, :lent_salary_template_id, :integer
    remove_column :lent_temporarily_items, :return_salary_template_id, :integer
  end
end
