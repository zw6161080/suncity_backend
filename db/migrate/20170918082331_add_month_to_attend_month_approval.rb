class AddMonthToAttendMonthApproval < ActiveRecord::Migration[5.0]
  def change
    remove_column :attend_month_approvals, :month, :integer
    add_column :attend_month_approvals, :month, :string
  end
end
