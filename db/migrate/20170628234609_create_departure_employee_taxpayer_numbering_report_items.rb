class CreateDepartureEmployeeTaxpayerNumberingReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :departure_employee_taxpayer_numbering_report_items do |t|
      t.datetime :year_month
      t.integer :user_id
      t.timestamps
    end
  end
end
