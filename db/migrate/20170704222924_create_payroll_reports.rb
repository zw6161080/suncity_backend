class CreatePayrollReports < ActiveRecord::Migration[5.0]
  def change
    create_table :payroll_reports do |t|
      t.datetime :year_month
      t.boolean :granted, default: false

      t.timestamps
    end

    add_reference :payroll_items, :payroll_report
  end
end
