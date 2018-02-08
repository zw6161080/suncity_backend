class AddStatusToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :status, :integer
  end
end
