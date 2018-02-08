class AddValidPeriodToPaidSickLeaveReportItem < ActiveRecord::Migration[5.0]
  def change
    add_column :paid_sick_leave_report_items, :valid_period, :date
  end
end
