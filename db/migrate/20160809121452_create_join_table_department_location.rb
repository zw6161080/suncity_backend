class CreateJoinTableDepartmentLocation < ActiveRecord::Migration[5.0]
  def change
    create_join_table :departments, :locations do |t|
      t.index [:department_id, :location_id]
    end
  end
end
