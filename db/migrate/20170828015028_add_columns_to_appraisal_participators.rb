class AddColumnsToAppraisalParticipators < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisal_participators, :appraisal_group, :string
    add_column :appraisal_participators, :appraisal_questionnaire_template_id, :integer
    add_column :appraisal_participators, :departmental_appraisal_group, :string
  end
end
