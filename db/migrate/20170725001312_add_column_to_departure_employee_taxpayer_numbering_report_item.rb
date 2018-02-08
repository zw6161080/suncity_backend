class AddColumnToDepartureEmployeeTaxpayerNumberingReportItem < ActiveRecord::Migration[5.0]
  def change
    add_column :departure_employee_taxpayer_numbering_report_items, :deployer_retirement_fund_number, :string
  end
end
