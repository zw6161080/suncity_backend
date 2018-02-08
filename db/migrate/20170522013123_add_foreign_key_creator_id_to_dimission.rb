class AddForeignKeyCreatorIdToDimission < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :creator_id, :integer
    add_foreign_key :dimissions, :users, column: :creator_id
    add_index :dimissions, :creator_id
  end
end
