class AddRenferenceToAppraisalParticipators < ActiveRecord::Migration[5.0]
  def change
    add_reference :appraisal_participators, :appraisal_department_setting, index: { :name => 'index_on_appraisal_participator_on_department_setting'}, foreign_key: true
  end
end
