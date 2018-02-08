class AddIsNextToSignCardRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :sign_card_records, :is_next, :boolean, default: false
  end
end
