module WelfareRecordHelper
  def welfare_required_array
    [:user_id, :change_reason]
  end

  def welfare_permitted_array
    [:welfare_begin, :welfare_end, :welfare_template_id, :comment, :annual_leave, :sick_leave, :office_holiday, :holiday_type, :probation, :notice_period,
     :double_pay, :reduce_salary_for_sick, :provide_uniform, :salary_composition, :over_time_salary, :force_holiday_make_up, :position_type, :work_days_every_week]
  end

end