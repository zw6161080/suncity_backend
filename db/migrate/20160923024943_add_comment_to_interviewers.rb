class AddCommentToInterviewers < ActiveRecord::Migration[5.0]
  def change
    add_column :interviewers, :comment, :text
  end
end
