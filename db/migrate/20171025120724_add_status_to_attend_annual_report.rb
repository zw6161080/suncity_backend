class AddStatusToAttendAnnualReport < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_annual_reports, :status, :integer
  end
end
