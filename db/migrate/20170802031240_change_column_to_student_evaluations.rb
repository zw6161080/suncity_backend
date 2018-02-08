class ChangeColumnToStudentEvaluations < ActiveRecord::Migration[5.0]
  def change
    remove_column :student_evaluations, :questionnaire_template_id, :integer
    remove_column :student_evaluations, :questionnaire_id, :integer
  end
end
