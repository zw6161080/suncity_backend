class ChangeColumnToSalaryValues < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_values, :month_salary_report_id, :integer
    add_column :salary_values, :year_month, :datetime
  end
end
