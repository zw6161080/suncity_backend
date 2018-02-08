class AddFieldsToDismissionSalaryItem < ActiveRecord::Migration[5.0]
  def change
    add_column :dismission_salary_items, :has_seniority_compensation, :boolean
    add_column :dismission_salary_items, :has_inform_period_compensation, :boolean
    add_column :dismission_salary_items, :approved, :boolean
  end
end
