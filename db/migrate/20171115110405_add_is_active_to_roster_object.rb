class AddIsActiveToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :is_active, :integer
  end
end
