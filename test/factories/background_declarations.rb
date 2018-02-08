FactoryGirl.define do
  factory :background_declaration do
    have_any_relatives 1
    relative_criminal_record 1
    relative_criminal_record_detail "MyString"
    relative_business_relationship_with_suncity 1
    relative_business_relationship_with_suncity_detail "MyString"
    user_id 1
  end
end
