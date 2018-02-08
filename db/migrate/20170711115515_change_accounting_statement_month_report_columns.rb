class ChangeAccountingStatementMonthReportColumns < ActiveRecord::Migration[5.0]
  def change
    change_column :accounting_statement_month_reports, :year_month, :datetime, null: false
    change_column :accounting_statement_month_reports, :granted, :boolean, default: false
  end
end
