class CreateBonusElementItemValues < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_element_item_values do |t|
      t.references :bonus_element_item, foreign_key: true
      t.references :bonus_element, foreign_key: true
      t.string :value_type
      t.decimal :shares, precision: 10, scale: 2
      t.decimal :per_share, precision: 10, scale: 2
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
