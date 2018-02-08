class CreateAppraisalQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_questionnaires do |t|

      t.references :appraisal, index: true, foreign_key: true
      t.references :appraisal_participator, index: true, foreign_key: true
      t.references :questionnaire, index: true, foreign_key: true
      t.boolean  :questionnaire_status
      t.datetime :submit_date
      t.datetime :latest_revise_date

      t.timestamps
    end

    add_reference :appraisal_questionnaires, :assess_participator, index: true
    add_foreign_key :appraisal_questionnaires, :appraisal_participators, column: :assess_participator_id

  end
end
