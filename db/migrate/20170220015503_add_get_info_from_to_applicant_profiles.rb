class AddGetInfoFromToApplicantProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_profiles, :get_info_from, :jsonb
  end
end
