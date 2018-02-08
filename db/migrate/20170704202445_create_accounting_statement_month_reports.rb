class CreateAccountingStatementMonthReports < ActiveRecord::Migration[5.0]
    def change
        create_table :accounting_statement_month_reports do |t|
          t.datetime :year_month
          t.boolean :granted, default: false
    
          t.timestamps
        end
  
      add_reference :accounting_statement_month_items,
                      :accounting_statement_month_report,
                      index: { name: 'index_accounting_statement_item_on_report_id' }
    end
  
  end