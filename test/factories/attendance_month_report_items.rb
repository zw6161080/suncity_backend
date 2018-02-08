FactoryGirl.define do
  factory :attendance_month_report_item do
    user nil
    normal_overtime_hours "9.99"
    holiday_overtime_hours "9.99"
    compulsion_holiday_compensation_days "9.99"
    public_holiday_compensation_days "9.99"
    absenteeism_days "9.99"
    immediate_leave_days ""
    unpaid_leave_days ""
    paid_sick_leave_days "9.99"
    unpaid_marriage_leave_days "9.99"
    unpaid_compassionate_leave_days "9.99"
    unpaid_maternity_leave_days "9.99"
    paid_maternity_leave_days "9.99"
    pregnant_sick_leave_days "9.99"
    occupational_injury_days "9.99"
    late_0_10_min_times 1
    late_10_20_min_times 1
    late_20_30_min_times 1
    late_30_120_min_times 1
    missing_punch_times 1
  end
end
