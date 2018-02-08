class RemoveColumnToMedicalInsuranceParticipators < ActiveRecord::Migration[5.0]
  def change
    remove_column :medical_insurance_participators, :medical_template_id, :integer
  end
end
