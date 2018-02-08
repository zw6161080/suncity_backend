FactoryGirl.define do
  factory :attachment_type do
    chinese_name { Faker::Lorem.word }
    english_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end

  factory :profile_attachment_type do 
    chinese_name { Faker::Lorem.word }
    english_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end

  factory :applicant_attachment_type do 
    chinese_name { Faker::Lorem.word }
    english_name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
  end

end

