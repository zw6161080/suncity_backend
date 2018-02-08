FactoryGirl.define do
  factory :class_setting do
    region 'macau'
    name 'class 1'
    display_name 'display class 1'
    start_time '10:00'
    end_time '16:00'
    late_be_allowed 30
    leave_be_allowed 30
    overtime_before_work 20
    overtime_after_work 20
    be_used false
    be_used_count 0
  end
end
