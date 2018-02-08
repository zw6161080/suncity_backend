class CreateGoodsCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :goods_categories do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :unit
      t.decimal :price_mop, precision: 15, scale: 2
      t.integer :distributed_count
      t.integer :returned_count
      t.integer :unreturned_count
      t.references :user

      t.timestamps
    end
  end
end
