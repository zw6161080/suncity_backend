class AddCompleteQuestionnaireToAppraisals < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisals, :complete_questionnaire, :boolean
  end
end
