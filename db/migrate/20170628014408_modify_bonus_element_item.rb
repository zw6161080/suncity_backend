class ModifyBonusElementItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_items, :year_month, :datetime
    add_reference :bonus_element_items, :float_salary_month_entry
  end
end
