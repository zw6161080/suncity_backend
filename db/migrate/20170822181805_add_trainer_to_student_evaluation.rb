class AddTrainerToStudentEvaluation < ActiveRecord::Migration[5.0]
  def change
    add_column :student_evaluations, :trainer, :string
  end
end
