class WelfareRecordReportSerializer < ActiveModel::Serializer
  attributes :id,
             :welfare_begin,
             :welfare_end,
             :welfare_end,
             :change_reason,
             :comment,
             :annual_leave,
             :sick_leave,
             :office_holiday,
             :holiday_type,
             :probation,
             :notice_period,
             :double_pay,
             :reduce_salary_for_sick,
             :provide_uniform,
             :salary_composition,
             :over_time_salary,
             :force_holiday_make_up

  belongs_to :user
  belongs_to :welfare_template

  def annual_leave
    if object.welfare_template_id
      object.welfare_template.annual_leave
    else
      object.annual_leave
    end
  end

  def sick_leave
    if object.welfare_template_id
      object.welfare_template.sick_leave
    else
      object.sick_leave
    end
  end

  def office_holiday
    if object.welfare_template_id
      object.welfare_template.office_holiday
    else
      object.office_holiday
    end
  end

  def holiday_type
    if object.welfare_template_id
      object.welfare_template.holiday_type
    else
      object.holiday_type
    end
  end

  def probation
    if object.welfare_template_id
      object.welfare_template.probation
    else
      object.probation
    end
  end

  def notice_period
    if object.welfare_template_id
      object.welfare_template.notice_period
    else
      object.notice_period
    end
  end

  def double_pay
    if object.welfare_template_id
      object.welfare_template.double_pay
    else
      object.double_pay
    end
  end

  def reduce_salary_for_sick
    if object.welfare_template_id
      object.welfare_template.reduce_salary_for_sick
    else
      object.reduce_salary_for_sick
    end
  end

  def provide_uniform
    if object.welfare_template_id
      object.welfare_template.provide_uniform
    else
      object.provide_uniform
    end
  end

  def salary_composition
    if object.welfare_template_id
      object.welfare_template.salary_composition
    else
      object.salary_composition
    end
  end

  def over_time_salary
    if object.welfare_template_id
      object.welfare_template.over_time_salary
    else
      object.over_time_salary
    end
  end

  def force_holiday_make_up
    if object.welfare_template_id
      object.welfare_template.force_holiday_make_up
    else
      object.force_holiday_make_up
    end
  end

  def work_days_every_week
    if object.welfare_template_id
      object.welfare_template.work_days_every_week
    else
      object.work_days_every_week
    end
  end

  def position_type
    if object.welfare_template_id
      object.welfare_template.position_type
    else
      object.position_type
    end
  end
end
