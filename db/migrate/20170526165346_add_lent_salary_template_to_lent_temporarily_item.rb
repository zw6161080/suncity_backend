class AddLentSalaryTemplateToLentTemporarilyItem < ActiveRecord::Migration[5.0]
  def change
    add_column :lent_temporarily_items, :lent_salary_template, :string
    add_column :lent_temporarily_items, :return_salary_template, :string
  end
end
