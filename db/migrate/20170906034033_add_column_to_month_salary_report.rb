class AddColumnToMonthSalaryReport < ActiveRecord::Migration[5.0]
  def change
    add_column :month_salary_reports, :salary_type, :string
  end
end
