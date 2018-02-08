class RemoveColumnFromAppraisalQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    remove_column :appraisal_questionnaires, :questionnaire_status, :boolean
    remove_column :appraisal_questionnaires, :latest_revise_date, :datetime
  end
end
