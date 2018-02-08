class AddPregnantSickLeaveToAttendAnnualReport < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_annual_reports, :pregnant_sick_leave_counts, :integer
  end
end
