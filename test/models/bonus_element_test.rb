require 'test_helper'

class BonusElementTest < ActiveSupport::TestCase
  setup do
    location_a = create(:location)
    location_a.departments << create(:department)
    location_a.departments << create(:department)
    location_a.departments << create(:department)
    location_a.save

    BonusElement.load_predefined
  end

  test "bonus elements load predefined" do

    bonus_elements_config = Config.get('bonus_elements')
    assert bonus_elements_config.keys.to_set.subset? BonusElement.pluck(:key).to_set
    BonusElement.all.each do |element|
      config = bonus_elements_config[element.key].except('value_type')
      config.each do |key, value|
        assert_equal element[key], value
      end
    end
  end

  test "test related settings created" do
    bonus_element = create(:bonus_element)
    Location.with_departments.each do |location|
      location['departments'].each do |department|
        assert 1, bonus_element
                   .bonus_element_settings
                   .where(location_id: location['id'], department_id: department['id'])
                   .count
      end
    end
  end

  test "should reload after create location or department" do
    department = create(:department)
    location = create(:location)
    location.departments << department
    location.save!

    assert BonusElementSetting.where(location_id: location.id, department_id: department.id).exists?
  end

end
