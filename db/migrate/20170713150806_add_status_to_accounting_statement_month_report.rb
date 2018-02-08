class AddStatusToAccountingStatementMonthReport < ActiveRecord::Migration[5.0]
  def change
    add_column :accounting_statement_month_reports, :status, :string, default: 'initial'
  end
end
