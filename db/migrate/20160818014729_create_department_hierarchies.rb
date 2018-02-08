class CreateDepartmentHierarchies < ActiveRecord::Migration
  def change
    create_table :department_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :department_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "department_anc_desc_idx"

    add_index :department_hierarchies, [:descendant_id],
      name: "department_desc_idx"
  end
end
