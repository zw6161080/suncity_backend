class AddRealWorkHoursToAttendAnnualReport < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_annual_reports, :real_working_hours, :integer
  end
end
