class RemoveColumnToMonthSalaryReports < ActiveRecord::Migration[5.0]
  def change
    remove_column :month_salary_reports, :salary_column_template_id, :integer


  end
end
