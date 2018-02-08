# == Schema Information
#
# Table name: locations
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  simple_chinese_name :string
#

FactoryGirl.define do
  factory :location do
    chinese_name {
      Faker::Company.location_name
    }

    english_name "office"
    region_key "macau"

    factory :location_with_sub_locations do
      transient do
        sub_location_count 2
      end

      after(:create) do |location, evaluator|
        # setting sublocations of location
        create_list(:location, evaluator.sub_location_count).each do |item|
          location.children << item
        end
      end

    end
  end
end
