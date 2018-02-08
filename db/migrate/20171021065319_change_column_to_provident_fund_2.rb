class ChangeColumnToProvidentFund2 < ActiveRecord::Migration[5.0]
  def change
    remove_column :provident_funds, :participation_date, :date
    add_column :provident_funds, :participation_date, :datetime
  end
end
