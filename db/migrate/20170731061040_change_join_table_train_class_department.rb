class ChangeJoinTableTrainClassDepartment < ActiveRecord::Migration[5.0]
  def change
    drop_table :train_classes_departments

    create_join_table :train_classes, :departments do |t|
      t.index [:train_class_id, :department_id], name: 'index_on_join_table_departments_train_classes'
    end
  end
end
