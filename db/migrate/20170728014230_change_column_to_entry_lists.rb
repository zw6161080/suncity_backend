class ChangeColumnToEntryLists < ActiveRecord::Migration[5.0]
  def change
    remove_column :entry_lists, :creator_id, :string
    add_column :entry_lists, :creator_id, :integer
  end
end
