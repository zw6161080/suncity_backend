class ChangeStatusDefaultInInterviewers < ActiveRecord::Migration[5.0]
  def change
    change_column_default :interviewers, :status, 4
  end
end
