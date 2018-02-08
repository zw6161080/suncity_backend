class CreateJoinTableDepartmentGroup < ActiveRecord::Migration[5.0]
  def change
    create_join_table :departments, :groups do |t|
      t.index [:department_id, :group_id]
    end
  end
end
