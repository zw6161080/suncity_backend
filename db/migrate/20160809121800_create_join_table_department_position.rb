class CreateJoinTableDepartmentPosition < ActiveRecord::Migration[5.0]
  def change
    create_join_table :departments, :positions do |t|
      t.index [:department_id, :position_id]
    end
  end
end
