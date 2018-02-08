FactoryGirl.define do
  factory :group do
    chinese_name {
      Faker::Company.group_name
    }
    english_name {
      Faker::Company.group_name
    }
    simple_chinese_name {
      Faker::Company.group_name
    }
  end
end
