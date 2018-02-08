class AddCommentToApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_positions, :comment, :text
  end
end
