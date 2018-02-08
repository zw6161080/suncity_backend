class AddColumnsToAnnualAwardReportItems < ActiveRecord::Migration[5.0]
  def change
    add_column :annual_award_report_items, :department_id, :integer
    add_column :annual_award_report_items, :position_id, :integer
    add_column :annual_award_report_items, :date_of_employment, :datetime
  end
end
