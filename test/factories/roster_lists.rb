FactoryGirl.define do
  factory :roster_list do
    region 'macau'
    status 1
    chinese_name 'chinese name'
    english_name 'english name'
    simple_chinese_name 'simple chinese name'
    location_id 1
    department_id 1
    date_range '2017/01/01~2017/02/01'
    start_date '2017/01/01'
    end_date '2017/02/01'
    employment_counts 10
    roster_counts 100
    general_holiday_counts 10
  end
end
