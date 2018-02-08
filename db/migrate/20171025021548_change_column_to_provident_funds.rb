class ChangeColumnToProvidentFunds < ActiveRecord::Migration[5.0]
  def change
    remove_column :provident_funds, :provident_fund_resignation_date, :date
    add_column :provident_funds, :provident_fund_resignation_date, :datetime
  end
end
