class CreateGoodsCategoryManagements < ActiveRecord::Migration[5.0]
  def change
    create_table :goods_category_managements do |t|
      t.string     :chinese_name, null: false, index: true
      t.string     :english_name, null: false, index: true
      t.string     :simple_chinese_name, null: false, index: true
      t.string     :unit, null: false, index: true
      t.decimal    :unit_price, precision:10, scale:2, null: false, index: true
      t.integer    :distributed_number, index: true
      t.integer    :collected_number, index: true
      t.integer    :unreturned_number, index: true
      t.references :creator, foreign_key: {to_table: :users}, index: true
      t.datetime   :create_date, index: true
      t.boolean    :can_be_delete

      t.timestamps
    end
  end
end
