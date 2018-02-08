FactoryGirl.define do
  factory :working_hours_transaction_record do
    region 'macau'
    user_a_id 1
    user_b_id 2
    is_compensate true
    apply_type 0
    apply_date '2017/01/01'
    start_time '10:00:00'
    end_time '11:00:00'
    hours_count 1
    is_deleted false
    creator_id 1
    comment 'comment'
  end
end
