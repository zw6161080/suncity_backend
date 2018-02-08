class CreateJoinTableTrainClassDepartment < ActiveRecord::Migration[5.0]
  def change
    create_table :train_classes_departments, id: false do |t|
      t.belongs_to :train_class, index: true
      t.belongs_to :department, index: true
    end
  end
end
