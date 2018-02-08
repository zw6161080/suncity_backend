class AddRegionToPermissions < ActiveRecord::Migration[5.0]
  def change
    add_column :permissions, :region, :string
    add_index :permissions, :region
  end
end
