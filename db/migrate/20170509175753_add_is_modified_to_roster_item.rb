class AddIsModifiedToRosterItem < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_items, :is_modified, :boolean
  end
end
