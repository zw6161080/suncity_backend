FactoryGirl.define do
  factory :typhoon_setting do
    start_date '2017/02/01'
    end_date '2017/02/03'
    start_time '10:00'
    end_time '21:00'
    qualify_counts 1
    apply_counts 0
  end
end
