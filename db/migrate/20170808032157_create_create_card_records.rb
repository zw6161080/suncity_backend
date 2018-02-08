class CreateCreateCardRecords < ActiveRecord::Migration[5.0]
  def change
    drop_table :card_records do |t|
      t.string :key
      t.string :action_type
      t.integer :current_user_id
      t.string :field_key
      t.string :file_category
      t.json :value1
      t.json :value2
      t.json :value
      t.references :card_profile, foreign_key: true

      t.timestamps
    end
    create_table :card_records do |t|
      t.string :key
      t.string :action_type
      t.integer :current_user_id
      t.string :field_key
      t.string :file_category
      t.json :value1
      t.json :value2
      t.json :value
      t.references :card_profile, foreign_key: true

      t.timestamps
    end
  end
end
