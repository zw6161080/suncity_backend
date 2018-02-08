class AddLentSalaryTemplateTypeToLentTemporarilyItem < ActiveRecord::Migration[5.0]
  def change
    add_column :lent_temporarily_items, :lent_salary_template_type, :string
    add_column :lent_temporarily_items, :return_salary_template_type, :string
  end
end
