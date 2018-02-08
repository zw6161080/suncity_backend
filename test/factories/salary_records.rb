FactoryGirl.define do
  factory :salary_record do
    user_id 100
    change_reason "entry"
    salary_begin "2017/01/01"
    salary_template_id nil
    basic_salary "1000"
    bonus "1000"
    attendance_award  "1000"
    new_year_bonus "1000"
    project_bonus  "1000"
    product_bonus  "1000"
    tea_bonus   "1000"
    kill_bonus        "1000"
    performance_bonus "1000"
    charge_bonus      "1000"
    commission_bonus  "1000"
    receive_bonus     "1000"
    exchange_rate_bonus "1000"
    guest_card_bonus  "1000"
    respect_bonus     "1000"
    comment           "1000"
    region_bonus      "1000"
    valid_date        "2017/01/01"
    invalid_date      nil
    order_key         nil
    house_bonus       "1000"
  end
end
