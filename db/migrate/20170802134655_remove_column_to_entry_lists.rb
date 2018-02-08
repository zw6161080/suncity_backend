class RemoveColumnToEntryLists < ActiveRecord::Migration[5.0]
  def change
    remove_column :entry_lists, :datetime, :string
    remove_column :entry_lists, :integer, :string
    remove_column :entry_lists, :string, :string

  end
end
