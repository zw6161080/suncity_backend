class CreateSelectColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :select_column_templates do |t|
      t.string :name, unique: true
      t.jsonb :select_column_keys
      t.boolean :default, default: false, index: true
      t.timestamps
    end
  end
end
