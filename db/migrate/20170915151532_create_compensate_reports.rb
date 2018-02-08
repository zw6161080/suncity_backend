class CreateCompensateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :compensate_reports do |t|
      t.integer :department_id
      t.integer :user_id
      t.integer :year
      t.integer :month
      t.integer :year_month

      t.integer :record_type

      t.integer :force_holiday_counts
      t.integer :force_holiday_for_leave_counts
      t.integer :force_holiday_for_money_counts
      t.integer :public_holiday_counts
      t.integer :public_holiday_for_leave_counts
      t.integer :public_holiday_for_money_counts

      t.integer :working_day_counts
      t.integer :general_holiday_counts

      t.integer :late_mins
      t.integer :late_counts
      t.integer :late_mins_less_than_10
      t.integer :late_mins_less_than_20
      t.integer :late_mins_less_than_30
      t.integer :late_mins_more_than_30
      t.integer :late_mins_more_than_120

      t.integer :leave_early_mins
      t.integer :leave_early_counts
      t.integer :leave_early_mins_not_include_allowable

      t.integer :sick_leave_counts_link_off
      t.integer :sick_leave_counts_not_link_off

      t.integer :annual_leave_counts
      t.integer :birthday_leave_counts
      t.integer :paid_bonus_leave_counts
      t.integer :compensatory_leave_counts
      t.integer :paid_sick_leave_counts
      t.integer :unpaid_sick_leave_counts
      t.integer :unpaid_leave_counts
      t.integer :paid_marriage_leave_counts
      t.integer :unpaid_marriage_leave_counts
      t.integer :paid_compassionate_leave_counts
      t.integer :unpaid_compassionate_leave_counts
      t.integer :maternity_leave_counts
      t.integer :paid_maternity_leave_counts
      t.integer :unpaid_maternity_leave_counts
      t.integer :immediate_leave_counts
      t.integer :absenteeism_counts
      t.integer :work_injury_before_7_counts
      t.integer :work_injury_after_7_counts
      t.integer :unpaid_but_maintain_position_counts
      t.integer :overtime_leave_counts

      t.integer :absenteeism_from_exception_counts

      t.integer :signcard_forget_to_punch_in_counts
      t.integer :signcard_forget_to_punch_out_counts
      t.integer :signcard_leave_early_counts
      t.integer :signcard_work_out_counts
      t.integer :signcard_others_counts
      t.integer :signcard_typhoon_counts

      t.integer :weekdays_overtime_hours
      t.integer :general_holiday_overtime_hours
      t.integer :force_holiday_overtime_hours
      t.integer :public_holiday_overtime_hours
      t.integer :vehicle_department_overtime_mins

      t.integer :as_a_in_borrow_hours_counts
      t.integer :as_b_in_borrow_hours_counts
      t.integer :as_a_in_return_hours_counts
      t.integer :as_b_in_return_hours_counts
      t.integer :typhoon_allowance_counts

      t.timestamps
    end
  end
end
