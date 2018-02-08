class AddColumnToStudentEvaluation < ActiveRecord::Migration[5.0]
  def change
    add_column :student_evaluations, :train_id, :integer
  end
end
