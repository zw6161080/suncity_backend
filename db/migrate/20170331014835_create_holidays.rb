class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.references :user, foreign_key: true
      t.integer :creator_id
      t.integer :item_count
      t.integer :status
      t.integer :category, null: false, default: 1
      t.datetime :apply_time
      t.text :comment
      t.timestamps
    end
  end
end
