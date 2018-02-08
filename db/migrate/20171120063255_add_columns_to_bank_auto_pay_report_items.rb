class AddColumnsToBankAutoPayReportItems < ActiveRecord::Migration[5.0]
  def change
    add_column :bank_auto_pay_report_items, :company_name, :string
    add_column :bank_auto_pay_report_items, :department_id, :integer
    add_column :bank_auto_pay_report_items, :position_id, :integer
    add_column :bank_auto_pay_report_items, :position_of_govt_record, :string
    add_column :bank_auto_pay_report_items, :id_number, :string
    add_column :bank_auto_pay_report_items, :bank_of_china_account_mop, :string
    add_column :bank_auto_pay_report_items, :bank_of_china_account_hkd, :string
  end
end
