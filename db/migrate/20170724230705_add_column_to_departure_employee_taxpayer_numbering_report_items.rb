class AddColumnToDepartureEmployeeTaxpayerNumberingReportItems < ActiveRecord::Migration[5.0]
  def change
    add_column :departure_employee_taxpayer_numbering_report_items, :beneficiary_name, :string
  end
end
