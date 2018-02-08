class ChangeColumnToMedicalInsuranceParticipators < ActiveRecord::Migration[5.0]
  def change
    add_column :medical_insurance_participators, :to_status, :string
    add_column :medical_insurance_participators, :valid_date, :datetime
    add_column :medical_insurance_participators, :profile_id, :integer

  end
end
