class AddApplicantPositionIdToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_reference :interviewers, :applicant_position, index: true
  end
end
