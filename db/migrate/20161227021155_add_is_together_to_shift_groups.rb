class AddIsTogetherToShiftGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :shift_groups, :is_together, :boolean, default: true
  end
end
