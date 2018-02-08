class AddLevelsToBonusElement < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_elements, :levels, :jsonb
    add_column :bonus_element_month_amounts, :level, :string
  end
end
