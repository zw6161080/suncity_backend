class ChangeAnnualAttendAwardToAttendAnnualReport < ActiveRecord::Migration[5.0]
  def change
    remove_column :attend_annual_reports, :annual_attend_award, :integer
    add_column :attend_annual_reports, :annual_attend_award, :decimal, precision: 15, scale: 2
  end
end
