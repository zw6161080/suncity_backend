class RemoveNestedSetsColumnFromLocationDepartmentPosition < ActiveRecord::Migration[5.0]
  def change
    remove_column :locations, :lft
    remove_column :locations, :rgt
    remove_column :locations, :depth
    remove_column :locations, :children_count

    remove_column :departments, :lft
    remove_column :departments, :rgt
    remove_column :departments, :depth
    remove_column :departments, :children_count

    remove_column :positions, :lft
    remove_column :positions, :rgt
    remove_column :positions, :depth
    remove_column :positions, :children_count
  end
end
