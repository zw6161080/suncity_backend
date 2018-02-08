class RemoveRoleIdFromPermissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :permissions, :role_id
  end
end
