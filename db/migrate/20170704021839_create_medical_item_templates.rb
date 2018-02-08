class CreateMedicalItemTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_item_templates do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.boolean :can_be_delete

      t.timestamps
    end

    remove_column :medical_items, :chinese_name, :string, null: false
    remove_column :medical_items, :english_name, :string, null: false
    remove_column :medical_items, :simple_chinese_name, :string, null: false
    remove_column :medical_items, :can_be_delete, :boolean

    add_reference :medical_items, :medical_item_template, foreign_key: true
    add_reference :medical_items, :medical_template, foreign_key: true
  end
end
