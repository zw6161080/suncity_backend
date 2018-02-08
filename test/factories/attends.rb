FactoryGirl.define do
  factory :attend do
    user_id 1
    attend_date '2017/01/01'
    attend_weekday 0
    roster_object_id nil
    on_work_time '12:00'
    off_work_time '13:00'
  end
end
