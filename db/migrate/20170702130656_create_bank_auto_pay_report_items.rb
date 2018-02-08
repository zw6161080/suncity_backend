class CreateBankAutoPayReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_auto_pay_report_items do |t|
      t.integer :record_type
      t.datetime :year_month
      t.datetime :balance_date
      t.integer :user_id
      t.decimal :amount_in_mop, precision: 15, scale: 2
      t.decimal :amount_in_hkd, precision: 15, scale: 2
      t.datetime :begin_work_date
      t.datetime :end_work_date
      t.string :cash_or_check
      t.boolean :leave_in_this_month
      t.timestamps
    end
  end
end
