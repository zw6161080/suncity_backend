class AddColumnToApplicantProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_profiles, :empoid_for_create_profile, :string
  end
end
