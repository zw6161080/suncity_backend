class ChangeColumnsToAppraisalParticipators < ActiveRecord::Migration[5.0]
  def change

    remove_column :appraisal_participators, :times_assessing_others, :integer
    remove_column :appraisal_participators, :times_assessed_by_superior, :integer
    remove_column :appraisal_participators, :times_assessed_by_colleague, :integer
    remove_column :appraisal_participators, :times_assessed_by_subordinate, :integer

    add_reference :appraisal_participators, :location, index: true, foreign_key: true

  end
end
