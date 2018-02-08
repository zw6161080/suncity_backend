class AddPregnantSickLeaveToAttendMonthlyReport < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_monthly_reports, :pregnant_sick_leave_counts, :integer
  end
end
