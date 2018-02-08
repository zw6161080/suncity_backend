class ChangeReferenceToAppraisalQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    remove_reference :appraisal_questionnaires, :assess_participator, index: true
    # remove_foreign_key :appraisal_questionnaires, :appraisal_participators, column: :assess_participator_id

    add_reference :appraisal_questionnaires, :assessor, index: true
    add_foreign_key :appraisal_questionnaires, :users, column: :assessor_id
  end
end
