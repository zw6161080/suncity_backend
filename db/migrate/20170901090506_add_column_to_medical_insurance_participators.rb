class AddColumnToMedicalInsuranceParticipators < ActiveRecord::Migration[5.0]
  def change
    add_column :medical_insurance_participators, :operator_id, :integer
  end
end
