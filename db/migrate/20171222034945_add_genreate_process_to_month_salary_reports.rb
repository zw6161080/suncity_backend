class AddGenreateProcessToMonthSalaryReports < ActiveRecord::Migration[5.0]
  def change
    add_column :month_salary_reports, :generate_process, :decimal, precision: 10, scale: 2
  end
end
