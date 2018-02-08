class AddSourceToApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_profiles, :source, :string
    add_index :applicant_profiles, :source
  end
end
