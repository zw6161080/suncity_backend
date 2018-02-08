class AddSalaryToApprovedJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :approved_jobs, :report_salary_count, :integer
    add_column :approved_jobs, :report_salary_unit, :string
  end
end
