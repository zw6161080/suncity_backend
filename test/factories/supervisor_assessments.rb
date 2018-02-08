FactoryGirl.define do
  factory :supervisor_assessment do
    id 1
    region 'macau'
    user_id 1
    employment_status 0
    exam_mode 0
    training_result 0
    attendance_rate 100
    score 100
    assessment_status 0
    filled_in_date '2017/02/01'
    comment 'comment'
  end
end
