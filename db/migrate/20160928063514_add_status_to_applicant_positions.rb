class AddStatusToApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_positions, :status, :integer, default: 0
  end
end
