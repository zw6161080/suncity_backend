class ChangeBonusElementItemValuesAmountDecimal < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_item_values, :per_share, :decimal, precision: 10, scale: 2
    add_column :bonus_element_item_values, :per_share, :decimal, precision: 15, scale: 4
  end
end
