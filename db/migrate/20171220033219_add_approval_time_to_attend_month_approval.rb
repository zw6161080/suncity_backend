class AddApprovalTimeToAttendMonthApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_month_approvals, :approval_time, :datetime
  end
end
