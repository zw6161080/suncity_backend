class ChangeReferenceToBonusElementItem < ActiveRecord::Migration[5.0]
  def change
    remove_column :bonus_element_items, :location_id, :integer
    remove_column :bonus_element_items, :department_id, :integer
    remove_column :bonus_element_items, :position_id, :integer

    add_reference :bonus_element_items, :location, index: true, foreign_key: true
    add_reference :bonus_element_items, :department, index: true, foreign_key: true
    add_reference :bonus_element_items, :position, index: true, foreign_key: true
  end
end
