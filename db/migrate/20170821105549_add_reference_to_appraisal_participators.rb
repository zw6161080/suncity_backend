class AddReferenceToAppraisalParticipators < ActiveRecord::Migration[5.0]
  def change
    add_reference :appraisal_participators, :appraisal_employee_setting, index: true, foreign_key: true
  end
end
