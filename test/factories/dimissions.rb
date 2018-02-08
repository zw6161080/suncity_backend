FactoryGirl.define do
  factory :dimission do
    user nil
    apply_date "2017-05-18"
    inform_date "2017-05-18"
    last_work_date "2017-05-18"
    is_in_blacklist false
    comment "MyText"
    last_salary_begin_date "2017-05-18"
    last_salary_end_date "2017-05-18"
    remaining_annual_holidays 1
    dimission_follow_ups []
    apply_comment "MyText"
    resignation_reason ""
    resignation_reason_extra "MyString"
    resignation_future_plan ""
    resignation_future_plan_extra "MyString"
    resignation_certificate_languages ["english", "chinese"]
    resignation_is_inform_period_exempted false
    resignation_inform_period_penalty 1
    resignation_is_recommanded_to_other_department false
    termination_reason ""
    termination_reason_extra "MyString"
    termination_inform_peroid_days 1
    termination_is_reasonable false
    termination_compensation 1
    termination_compensation_extra "MyString"
    dimission_type "resignation"
    career_history_dimission_reason "other"
    career_history_dimission_comment "test comment"
  end
end
