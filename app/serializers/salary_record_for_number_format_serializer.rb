class SalaryRecordForNumberFormatSerializer < ActiveModel::Serializer
  attributes *SalaryRecord.column_names,
             :final_basic_salary,
             :final_bonus,
             :final_attendance_award,
             :final_house_bonus,
             :final_tea_bonus,
             :final_kill_bonus,
             :final_performance_bonus,
             :final_charge_bonus,
             :final_commission_bonus,
             :final_receive_bonus,
             :final_exchange_rate_bonus,
             :final_guest_card_bonus,
             :final_respect_bonus,
             :final_new_year_bonus,
             :final_project_bonus,
             :final_product_bonus,
             :final_region_bonus,
             :final_service_award,
             :final_internship_bonus,
             :final_performance_award,
             :final_special_tie_bonus
  belongs_to :user
  belongs_to :salary_template

  def final_basic_salary
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.basic_salary) + SalaryCalculatorService.math_add(object.salary_template.basic_salary)
    else
      SalaryCalculatorService.math_add(object.basic_salary)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.bonus) + SalaryCalculatorService.math_add(object.salary_template.bonus)
    else
      SalaryCalculatorService.math_add(object.bonus)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_attendance_award
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.attendance_award)+ SalaryCalculatorService.math_add(object.salary_template.attendance_award)
    else
      SalaryCalculatorService.math_add(object.attendance_award)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_house_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.house_bonus) + SalaryCalculatorService.math_add(object.salary_template.house_bonus)
    else
      SalaryCalculatorService.math_add(object.house_bonus)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_tea_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.tea_bonus)+ SalaryCalculatorService.math_add(object.salary_template.tea_bonus)
    else
      SalaryCalculatorService.math_add(object.tea_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_kill_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.kill_bonus)+ SalaryCalculatorService.math_add(object.salary_template.kill_bonus)
    else
      SalaryCalculatorService.math_add object.kill_bonus
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_performance_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.performance_bonus)+ SalaryCalculatorService.math_add(object.salary_template.performance_bonus)
    else
      SalaryCalculatorService.math_add(object.performance_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_charge_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.charge_bonus)+ SalaryCalculatorService.math_add(object.salary_template.charge_bonus)
    else
      SalaryCalculatorService.math_add(object.charge_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_commission_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.commission_bonus)+ SalaryCalculatorService.math_add(object.salary_template.commission_bonus)
    else
      SalaryCalculatorService.math_add(object.commission_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_receive_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.receive_bonus)+ SalaryCalculatorService.math_add(object.salary_template.receive_bonus)
    else
      SalaryCalculatorService.math_add(object.receive_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_exchange_rate_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.exchange_rate_bonus) + SalaryCalculatorService.math_add(object.salary_template.exchange_rate_bonus)
    else
      SalaryCalculatorService.math_add object.exchange_rate_bonus
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_guest_card_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.guest_card_bonus) + SalaryCalculatorService.math_add(object.salary_template.guest_card_bonus)
    else
      SalaryCalculatorService.math_add(object.guest_card_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_respect_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.respect_bonus)+ SalaryCalculatorService.math_add(object.salary_template.respect_bonus)
    else
      SalaryCalculatorService.math_add(object.respect_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_new_year_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.new_year_bonus) + SalaryCalculatorService.math_add(object.salary_template.new_year_bonus)
    else
      SalaryCalculatorService.math_add object.new_year_bonus
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_project_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.project_bonus)+ SalaryCalculatorService.math_add(object.salary_template.project_bonus)
    else
      SalaryCalculatorService.math_add object.project_bonus
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_product_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.product_bonus) + SalaryCalculatorService.math_add(object.salary_template.product_bonus)
    else
      SalaryCalculatorService.math_add object.product_bonus
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_region_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.region_bonus) + SalaryCalculatorService.math_add(object.salary_template.region_bonus)
    else
      SalaryCalculatorService.math_add(object.region_bonus)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_service_award
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.service_award) + SalaryCalculatorService.math_add(object.salary_template.service_award)
    else
      SalaryCalculatorService.math_add(object.service_award)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_internship_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.internship_bonus) + SalaryCalculatorService.math_add(object.salary_template.internship_bonus)
    else
      SalaryCalculatorService.math_add(object.internship_bonus)
    end.to_s.sub(/\.\d*/, '').to_s
  end

  def final_performance_award
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.performance_award) + SalaryCalculatorService.math_add(object.salary_template.performance_award)
    else
      SalaryCalculatorService.math_add(object.performance_award)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def final_special_tie_bonus
    if object.salary_template_id
      SalaryCalculatorService.math_add(object.special_tie_bonus) + SalaryCalculatorService.math_add(object.salary_template.special_tie_bonus)
    else
      SalaryCalculatorService.math_add(object.special_tie_bonus)
    end.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end
end
