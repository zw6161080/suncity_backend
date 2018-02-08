FactoryGirl.define do
  factory :student_evaluation do
    id 1
    region 'macau'
    user_id 1
    employment_status 0
    training_type 0
    lecturer_id 1
    satisfaction 100
    evaluation_status 0
    filled_in_date '2017/02/01'
    comment 'comment'
  end
end
