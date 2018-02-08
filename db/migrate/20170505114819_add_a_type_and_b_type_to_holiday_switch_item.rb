class AddATypeAndBTypeToHolidaySwitchItem < ActiveRecord::Migration[5.0]
  def change
    add_column :holiday_switch_items, :a_type, :string
    add_column :holiday_switch_items, :b_type, :string
  end
end
