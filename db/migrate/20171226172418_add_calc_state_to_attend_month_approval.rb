class AddCalcStateToAttendMonthApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_month_approvals, :calc_state, :integer
  end
end
