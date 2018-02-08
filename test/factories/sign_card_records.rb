FactoryGirl.define do
  factory :sign_card_record do
    region 'macau'
    user_id 1
    is_compensate true
    is_get_to_work true
    sign_card_date '2017/01/01'
    sign_card_time '10:00:00'
    sign_card_setting_id 1
    sign_card_reason_id 1
    is_deleted false
    creator_id 1
    comment 'comment'
  end
end
