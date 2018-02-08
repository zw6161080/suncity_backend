class ChangeColummnToPerformanceInterviews < ActiveRecord::Migration[5.0]
  def change
    remove_column :performance_interviews, :performance_status, :boolean
    add_column :performance_interviews, :performance_interview_status, :string
  end
end
