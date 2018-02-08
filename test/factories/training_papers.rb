FactoryGirl.define do
  factory :training_paper do
    id 1
    region 'macau'
    user_id 1
    employment_status 0
    exam_mode 0
    score 100
    attendance_rate 100
    paper_status 0
    correct_percentage 100
    filled_in_date '2017/02/01'
    latest_upload_date '2017/06/01'
    comment 'comment'
  end
end
