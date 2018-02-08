class CreateAttendMonthApprovals < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_month_approvals do |t|
      t.integer :month
      t.integer :status
      t.integer :employee_counts

      t.integer :roster_counts
      t.integer :general_holiday_counts
      t.integer :punching_counts
      t.integer :punching_exception_counts

      t.timestamps
    end
  end
end
