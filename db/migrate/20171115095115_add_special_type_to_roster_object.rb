class AddSpecialTypeToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :special_type, :integer
  end
end
