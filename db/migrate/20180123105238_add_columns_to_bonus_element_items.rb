class AddColumnsToBonusElementItems < ActiveRecord::Migration[5.0]
  def change
    add_column :bonus_element_items, :location_id, :integer
    add_column :bonus_element_items, :department_id, :integer
    add_column :bonus_element_items, :position_id, :integer
  end
end
