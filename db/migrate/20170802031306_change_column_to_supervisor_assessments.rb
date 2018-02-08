class ChangeColumnToSupervisorAssessments < ActiveRecord::Migration[5.0]
  def change
    remove_column :supervisor_assessments , :questionnaire_template_id, :integer
    remove_column :supervisor_assessments, :questionnaire_id, :integer
  end
end
