class ChangeColumnToBonusElementMonthAmounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_month_amounts, :amount, :decimal, precision: 10, scale: 2
    add_column :bonus_element_month_amounts, :amount, :decimal, precision: 15, scale: 4
  end
end
