FactoryGirl.define do
  factory :holiday_setting do
    region 'macau'
    chinese_name 'chinese name'
    english_name 'english name'
    simple_chinese_name 'simple chinese name'
    category 0
    holiday_date '2017/01/01'
    comment 'comment'
  end
end
