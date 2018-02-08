module MedicalInformationHelper
  include GetProfileInformationHelper
  def formed_create_params(medical_information_params)
    to_status = medical_information_params['to_status']
    valid_date =Time.zone.parse(medical_information_params['valid_date'])
    if valid_date && valid_date >= beginning_of_next_day
      {valid_date: 'join', valid_date: valid_date , to_status: to_status}
    elsif valid_date && valid_date <= beginning_of_next_day
      {current_status: to_status, valid_date: nil, to_status: nil, join_date: valid_date}
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
    Time.zone.now.to_date + 1.day
  end
end