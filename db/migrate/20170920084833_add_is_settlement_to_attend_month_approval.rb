class AddIsSettlementToAttendMonthApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_month_approvals, :is_settlement, :boolean
  end
end
