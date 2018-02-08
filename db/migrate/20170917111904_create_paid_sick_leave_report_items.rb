class CreatePaidSickLeaveReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :paid_sick_leave_report_items do |t|
      t.integer :paid_sick_leave_report_id
      t.integer :year
      t.integer :department_id
      t.integer :user_id
      t.date :entry_date
      t.integer :on_duty_days
      t.integer :paid_sick_leave_counts
      t.integer :obtain_counts
      t.boolean :is_release
      t.timestamps
    end
  end
end
