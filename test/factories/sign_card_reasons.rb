FactoryGirl.define do
  factory :sign_card_reason do
    region 'macau'
    sign_card_setting_id 1
    reason 'reason'
    reason_code 'a'
    be_used false
    be_used_count 0
    comment 'comment'
  end
end
