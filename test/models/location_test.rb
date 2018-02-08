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

require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  SUB_DEPARTMENTS_COUNT = 3

  setup do
    @location_a = create(:location)
    @location_b = create(:location)

    SUB_DEPARTMENTS_COUNT.times {
      @location_a.departments << create(:department)
      @location_b.departments << create(:department)
    }
    @location_a.departments << create(:department, status: 1)
    @location_b.departments << create(:department, status: 1)
    @location_a.save
    @location_b.save
  end

  test 'create location' do
    name = Faker::Name.name
    location = Location.new
    location.chinese_name = name
    location.region_key = 'macau'
    assert location.save
  end

  test 'all locations with departments information' do
    locations = Location.with_departments
    assert [@location_a.id, @location_b.id].to_set.subset? locations.pluck('id').to_set

    assert locations
             .select { |loc| [@location_a.id, @location_b.id].include? loc['id'] }
             .all? { |loc| loc['departments'].count == SUB_DEPARTMENTS_COUNT }
  end
end
