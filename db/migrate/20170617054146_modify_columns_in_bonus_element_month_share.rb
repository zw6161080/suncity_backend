class ModifyColumnsInBonusElementMonthShare < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_month_shares, :key, :string
    remove_column :bonus_element_month_shares, :year_month, :string
    remove_column :bonus_element_month_shares, :chinese_name, :string
    remove_column :bonus_element_month_shares, :english_name, :string
    remove_column :bonus_element_month_shares, :simple_chinese_name, :string
    remove_reference :bonus_element_month_shares, :position
    add_reference :bonus_element_month_shares, :department
  end
end
