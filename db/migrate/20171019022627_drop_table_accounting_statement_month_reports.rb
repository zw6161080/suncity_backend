class DropTableAccountingStatementMonthReports < ActiveRecord::Migration[5.0]
  def change
    drop_table :accounting_statement_month_reports
  end
end
