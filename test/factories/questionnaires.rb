FactoryGirl.define do
  factory :questionnaire do
    id 1
    region 'macau'
    questionnaire_template_id 1
    user_id 1
    is_filled_in true
    release_date '2017/06/20'
    release_user_id 1
    submit_date '2017/06/21'
    comment 'comment'
  end
end
