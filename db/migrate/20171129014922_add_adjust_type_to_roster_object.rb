class AddAdjustTypeToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :adjust_type, :string
  end
end
