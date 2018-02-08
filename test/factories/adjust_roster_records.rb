FactoryGirl.define do
  factory :adjust_roster_record do
    region 'macau'
    user_a_id 1
    user_b_id 2
    user_a_adjust_date '2017/01/01'
    user_b_adjust_date '2017/01/02'
    user_a_roster_id 1
    user_b_roster_id 2
    apply_type 0
    is_director_special_approval false
    is_deleted false
    comment 'comment'
  end
end
