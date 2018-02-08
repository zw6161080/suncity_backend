FactoryGirl.define do
  factory :card_attachment do
    category "passport"
    file_name "MyString"
    comment "MyText"
    attachment_id 1
    card_profile nil
  end
end
