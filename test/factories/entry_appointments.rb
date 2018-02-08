FactoryGirl.define do
  factory :entry_appointment do
    id 1
    region 'macau'
    user_id 1
    status 0
    questionnaire_template_id 1
    questionnaire_id 1
    appointment_date '2017/02/01'
    appointment_time '12:00'
    appointment_location 'home'
    appointment_description 'description'
    opinion 'opinion'
    other_opinion 'other opinion'
    summary 'summary'
    inputter_id 1
    input_date '2017/06/01'
    comment 'comment'
  end
end
