class CreateOnlineMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :online_materials do |t|
      t.string :name
      t.string :file_name
      t.integer :creator_id
      t.string :instruction

      t.string :attachable_type
      t.integer :attachable_id

      t.timestamps
    end
    add_index :online_materials, [:attachable_type, :attachable_id]
  end
end
