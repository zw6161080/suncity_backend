class AddColumnToContributionReportItems < ActiveRecord::Migration[5.0]
  def change
    add_column :contribution_report_items, :department_id, :integer
    add_column :contribution_report_items, :position_id, :integer
    add_column :contribution_report_items, :grade, :integer
    add_column :contribution_report_items, :member_retirement_fund_number, :string
  end
end
