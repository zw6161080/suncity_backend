FactoryGirl.define do
  factory :career_record do
    user_id 1
    career_begin "2017/01/01"
    career_end nil
    deployment_type "entry"
    trial_period_expiration_date nil
    salary_calculation "do_not_adjust_the_salary"
    company_name "tian_mao_yi_hang"
    location_id 32
    position_id 1
    department_id 1
    grade 1
    division_of_job "back_office"
    deployment_instructions nil
    inputer_id 100
    comment nil
    employment_status "formal_employees"
    valid_date "2017/01/01"
    invalid_date nil
    order_key nil
  end
end
