class AddStatusToAttendMonthlyReport < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_monthly_reports, :status, :integer
  end
end
