class CreatePositionHierarchies < ActiveRecord::Migration
  def change
    create_table :position_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :position_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "position_anc_desc_idx"

    add_index :position_hierarchies, [:descendant_id],
      name: "position_desc_idx"
  end
end
