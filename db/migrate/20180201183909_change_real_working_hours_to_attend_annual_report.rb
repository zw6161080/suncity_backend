class ChangeRealWorkingHoursToAttendAnnualReport < ActiveRecord::Migration[5.0]
  def change
    remove_column :attend_annual_reports, :real_working_hours, :integer
    add_column :attend_annual_reports, :real_working_hours, :float
  end
end
