# == Schema Information
#
# Table name: positions
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  number              :string
#  grade               :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  simple_chinese_name :string
#

FactoryGirl.define do
  factory :position do
    chinese_name {
      Faker::Company.position_name
    }

    region_key 'macau'
    english_name 'Business Development'

    grade '6'

    factory :position_with_full_relations do
      transient do
        locations_count 2
        departments_count 2
      end

      after(:create) do |position, evaluator|
        locations = create_list(:location_with_sub_locations, evaluator.locations_count)
        departments = create_list(:department_with_locations, evaluator.departments_count)
        # setting locations of position
        position.location_ids = locations.map(&:id)

        # setting departments of position
        position.department_ids = departments.map(&:id)
      end

    end
  end
end
