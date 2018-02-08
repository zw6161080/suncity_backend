class ChangeStatusDefaultToNotStartedInApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    change_column_default :applicant_positions, :status, 0
  end
end
