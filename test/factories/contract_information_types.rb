FactoryGirl.define do
  factory :contract_information_type do
    chinese_name { Faker::Lorem.word }
    english_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end

end
