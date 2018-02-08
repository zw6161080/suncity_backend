class ChangeColumnToProvidentFund < ActiveRecord::Migration[5.0]
  def change
    remove_column :provident_funds, :provident_fund_resignation_reason, :date
    add_column :provident_funds, :provident_fund_resignation_reason, :string
    add_column :provident_funds, :user_id, :integer
  end
end
