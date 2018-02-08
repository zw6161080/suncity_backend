class ChangeColumnToLoveFund < ActiveRecord::Migration[5.0]
  def change
    add_column :love_funds, :to_status, :string
    add_column :love_funds, :valid_date, :datetime
    add_column :love_funds, :profile_id, :integer




  end
end
