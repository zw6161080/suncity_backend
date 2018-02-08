class AddIdCardNumberToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :id_card_number, :string
    add_index :users, :chinese_name
    add_index :users, :english_name
    add_index :users, :id_card_number
  end
end
