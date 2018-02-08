class AddCreaterIdToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :creater_id, :integer
  end
end
