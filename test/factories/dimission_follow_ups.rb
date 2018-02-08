FactoryGirl.define do
  factory :dimission_follow_up do
    dimission nil
    event_key "MyString"
    return_number 1
    compensation "9.99"
    is_confirmed false
    handler_id 1
    is_checked false
  end
end
