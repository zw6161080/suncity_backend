class SalaryTemplateForExportSerializer < ActiveModel::Serializer
  attributes *SalaryTemplate.create_params, :belongs_to_string, :belongs_to, :total_count, :id, :template_name

  def template_name
    object.template_chinese_name
  end

  def total_count
    [
      object.region_bonus, object.basic_salary, object.bonus, object.attendance_award, object.house_bonus,
      object.service_award, object.internship_bonus
    ].compact.sum.to_s.sub(/\.\d*/, '').to_s
  end

  def belongs_to_string
    object.belongs_to_string
  end

  def new_year_bonus
    object.new_year_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def project_bonus
    object.project_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def product_bonus
    object.product_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def tea_bonus
    object.tea_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def kill_bonus
    object.kill_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def performance_bonus
    object.performance_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def charge_bonus
    object.charge_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end


  def commission_bonus
    object.commission_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def receive_bonus
    object.receive_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def exchange_rate_bonus
    object.exchange_rate_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end


  def guest_card_bonus
    object.guest_card_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def respect_bonus
    object.respect_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def region_bonus
    object.region_bonus.to_s.sub(/\.\d*/, '').to_s
  end

  def basic_salary
    object.basic_salary.to_s.sub(/\.\d*/, '').to_s
  end

  def bonus
    object.bonus.to_s.sub(/\.\d*/, '').to_s
  end

  def attendance_award
    object.attendance_award.to_s.sub(/\.\d*/, '').to_s
  end

  def house_bonus
    object.house_bonus.to_s.sub(/\.\d*/, '').to_s
  end

  def service_award
    object.service_award.to_s.sub(/\.\d*/, '').to_s
  end

  def internship_bonus
    object.internship_bonus.to_s.sub(/\.\d*/, '').to_s
  end

  def performance_award
    object.performance_award.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

  def special_tie_bonus
    object.special_tie_bonus.to_s.send(:+, '0').match(/\d*\.\d\d/).to_s
  end

end