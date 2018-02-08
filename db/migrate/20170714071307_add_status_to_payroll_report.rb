class AddStatusToPayrollReport < ActiveRecord::Migration[5.0]
  def change
    add_column :payroll_reports, :status, :string, default: 'initial'
  end
end
