class AddColumnsToAnnaulAwardReportItems < ActiveRecord::Migration[5.0]
  def change
    add_column :annual_award_report_items, :work_days_this_year, :decimal, precision: 15, scale: 2
    add_column :annual_award_report_items, :deducted_days, :decimal, precision: 15, scale: 2
  end
end
