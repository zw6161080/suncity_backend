class ModifyColumnsInBonusElementMonthAmount < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_month_amounts, :key, :string
    remove_column :bonus_element_month_amounts, :year_month, :datetime
    remove_column :bonus_element_month_amounts, :chinese_name, :string
    remove_column :bonus_element_month_amounts, :english_name, :string
    remove_column :bonus_element_month_amounts, :simple_chinese_name, :string
    remove_reference :bonus_element_month_amounts, :position
    add_reference :bonus_element_month_amounts, :department
  end
end
