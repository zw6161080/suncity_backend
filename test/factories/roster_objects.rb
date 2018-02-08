FactoryGirl.define do
  factory :roster_object do
    region 'macau'
    user_id 1
    location_id 1
    department_id 1
    roster_date '2017/01/01'
    roster_list_id 1
    class_setting_id 1
    is_general_holiday false
  end
end
