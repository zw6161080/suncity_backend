class RenameColumnToEntryList < ActiveRecord::Migration[5.0]
  def change
    rename_column :entry_lists, :title_class_id, :title_id
  end
end
