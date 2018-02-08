class CreateAppraisalReports < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_reports do |t|
      t.references :user, index: true, foregin_key: true
      t.references :appraisal_participator, index: true, foreign_key: true
      t.references :appraisal_questionnaire, index: true, foreign_key: true
      t.jsonb      :questionnaire_score
      t.timestamps
    end
  end
end
