class WelfareRecordSerializer < ActiveModel::Serializer
  attributes *WelfareRecord.column_names
  belongs_to :welfare_template, serializer: WelfareTemplateForJobTransferSerializer
  belongs_to :user
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
