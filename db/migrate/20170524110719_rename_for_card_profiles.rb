class RenameForCardProfiles < ActiveRecord::Migration[5.0]
  def change
    rename_column :card_profiles, :approved_job_id, :approved_job_number
  end
end
