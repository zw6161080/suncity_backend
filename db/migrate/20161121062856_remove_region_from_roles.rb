class RemoveRegionFromRoles < ActiveRecord::Migration[5.0]
  def change
    remove_column :roles, :region
  end
end
