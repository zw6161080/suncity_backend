class AddSubTypesToBonusElement < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_elements, :subtypes, :jsonb
    add_column :bonus_element_item_values, :subtype, :string
    add_column :bonus_element_month_amounts, :subtype, :string
  end
end
