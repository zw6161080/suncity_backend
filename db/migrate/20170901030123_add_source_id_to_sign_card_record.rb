class AddSourceIdToSignCardRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :sign_card_records, :source_id, :integer
  end
end
