# == Schema Information
#
# Table name: departments
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  head_id             :integer
#  simple_chinese_name :string
#

FactoryGirl.define do
  factory :department do
    chinese_name {
      Faker::Company.department_name
    }

    english_name "Information Technology"

    region_key "macau"
    comment "这个部门猴赛雷🐒"

    factory :department_with_locations do
      transient do
        locations_count 2
      end

      after(:create) do |department, evaluator|
        locations = create_list(:location_with_sub_locations, evaluator.locations_count)
        # setting locations of department
        department.location_ids = locations.map(&:id)
      end

    end
  end
end
