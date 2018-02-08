class DorpTableAttendReturnApproval < ActiveRecord::Migration[5.0]
  def change
    drop_table :attend_return_approvals
  end
end
