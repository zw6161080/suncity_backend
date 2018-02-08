class CreateMonthSalaryReports < ActiveRecord::Migration[5.0]
  def change
    create_table :month_salary_reports do |t|
      t.string :status
      t.datetime :year_month
      t.integer :salary_column_template_id
      t.timestamps
    end
  end
end
