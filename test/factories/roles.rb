# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  chinese_name :string
#  english_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :role do
    chinese_name { Faker::Lorem.sentence }
    english_name { Faker::Lorem.sentence }
  end
end
