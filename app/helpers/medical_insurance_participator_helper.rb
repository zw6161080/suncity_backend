module MedicalInsuranceParticipatorHelper
  include GetProfileInformationHelper
  def formed_create_params(medical_information_params)
    to_status = medical_information_params['to_status']
    valid_date =Time.zone.parse(medical_information_params['valid_date'])
    if valid_date && valid_date >= beginning_of_next_day
      if to_status == 'not_participated_in_the_future'
        { valid_date: valid_date , to_status: to_status, cancel_date: valid_date}
      else
        { valid_date: valid_date , to_status: to_status, participate_date: valid_date}
      end
    elsif valid_date && valid_date < beginning_of_next_day
      if to_status ==  'not_participated_in_the_future'
        {participate: 'not_participated', valid_date: nil, to_status: nil, cancel_date: valid_date, monthly_deduction: BigDecimal(0), medical_template_id: nil}
      else
        {participate: 'participated', valid_date: nil, to_status: nil, participate_date: valid_date, monthly_deduction: BigDecimal('50')}
      end
    else
      {}
    end
  end

  def get_medical_template_up_to_grade(profile)
    grade = get_grade(profile) rescue nil
    if grade
      MedicalTemplateSetting.load_predefined
      right_setting =  MedicalTemplateSetting.first.sections.select do |hash|
        hash['employee_grade'] == grade
      end.try(:first)
      right_setting['current_template_id'] if right_setting
    else
      nil
    end
  end
  private
  def beginning_of_next_day
    (Time.zone.now + 1.day).beginning_of_day
  end
end