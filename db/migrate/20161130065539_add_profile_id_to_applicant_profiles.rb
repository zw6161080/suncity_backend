class AddProfileIdToApplicantProfiles < ActiveRecord::Migration[5.0]
  def change
    add_reference :applicant_profiles, :profile, index: true
  end
end
