class AddHeadIdToDepartments < ActiveRecord::Migration[5.0]
  def change
    add_column :departments, :head_id, :integer
  end
end
