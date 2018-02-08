class CreateJoinTableTrainDepartment < ActiveRecord::Migration[5.0]
  def change
    create_join_table :trains, :departments do |t|
      t.index [:train_id, :department_id]
    end
  end
end
