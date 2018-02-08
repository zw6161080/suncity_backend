FactoryGirl.define do
  factory :overtime_record do
    region 'macau'
    user_id 1
    is_compensate true
    overtime_type 0
    compensate_type 0
    overtime_start_date '2017/01/01'
    overtime_end_date '2017/01/01'
    overtime_start_time '10:00:00'
    overtime_end_time '11:00:00'
    overtime_hours 1
    vehicle_department_over_time_min 10
    is_deleted false
    creator_id 1
    comment 'comment'
  end
end
