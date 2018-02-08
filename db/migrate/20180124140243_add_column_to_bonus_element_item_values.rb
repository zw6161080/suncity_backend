class AddColumnToBonusElementItemValues < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_element_item_values, :basic_salary, :decimal, precision: 10, scale: 2
  end
end
