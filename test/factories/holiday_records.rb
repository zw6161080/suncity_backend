FactoryGirl.define do
  factory :holiday_record do
    region 'macau'
    user_id 1
    is_compensate true
    holiday_type 0
    start_date '2017/01/01'
    start_time '10:00:00'
    end_date '2017/02/01'
    end_time '11:00:00'
    days_count 1
    hours_count 2
    year 2017
    is_deleted false
    creator_id 1
    comment 'comment'
  end
end
