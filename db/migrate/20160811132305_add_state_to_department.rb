class AddStateToDepartment < ActiveRecord::Migration[5.0]
  def change
    add_column :departments, :status, :integer, default: 0
    add_column :positions, :status, :integer, default: 0
  end
end
