class ChangeColumnToStudentEvaluations1 < ActiveRecord::Migration[5.0]
  def change
    remove_column :student_evaluations, :satisfaction, :integer
    add_column :student_evaluations, :satisfaction, :decimal, precision: 15, scale: 2
  end
end
