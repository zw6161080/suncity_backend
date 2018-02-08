class CreateAttendanceMonthReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_month_report_items do |t|
      t.references :user, foreign_key: true
      t.date :year_month
      t.decimal :normal_overtime_hours, precision: 10, scale: 2
      t.decimal :holiday_overtime_hours, precision: 10, scale: 2
      t.decimal :compulsion_holiday_compensation_days, precision: 10, scale: 2
      t.decimal :public_holiday_compensation_days, precision: 10, scale: 2
      t.decimal :absenteeism_days, precision: 10, scale: 2
      t.decimal :immediate_leave_days, precision: 10, scale: 2
      t.decimal :unpaid_leave_days, precision: 10, scale: 2
      t.decimal :paid_sick_leave_days, precision: 10, scale: 2
      t.decimal :unpaid_marriage_leave_days, precision: 10, scale: 2
      t.decimal :unpaid_compassionate_leave_days, precision: 10, scale: 2
      t.decimal :unpaid_maternity_leave_days, precision: 10, scale: 2
      t.decimal :paid_maternity_leave_days, precision: 10, scale: 2
      t.decimal :pregnant_sick_leave_days, precision: 10, scale: 2
      t.decimal :occupational_injury_days, precision: 10, scale: 2
      t.integer :late_0_10_min_times
      t.integer :late_10_20_min_times
      t.integer :late_20_30_min_times
      t.integer :late_30_120_min_times
      t.integer :missing_punch_times

      t.timestamps

      t.index :year_month
    end
  end
end
