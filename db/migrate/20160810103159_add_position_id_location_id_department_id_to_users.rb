class AddPositionIdLocationIdDepartmentIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :position_id, :integer
    add_column :users, :location_id, :integer
    add_column :users, :department_id, :integer
  end
end
