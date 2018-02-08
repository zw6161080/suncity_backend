require 'test_helper'

class SalaryElementCategoryTest < ActiveSupport::TestCase
  test "predefined loaded" do
    SalaryElementCategory.load_predefined
    SalaryElementCategory.load_predefined

    all_categories_config = Config.get('salary_element_categories')
    all_elements_config = Config.get('salary_elements')
    all_factors_config = Config.get('salary_element_factors')

    assert_equal all_categories_config.keys.to_set, SalaryElementCategory.pluck(:key).to_set
    assert SalaryElement.count > 0
    assert SalaryElement.pluck(:key).to_set.subset?(all_elements_config.keys.to_set)
    assert SalaryElementFactor.count > 0
    assert SalaryElementFactor.pluck(:key).to_set.subset?(all_factors_config.keys.to_set)

    display_template = ActiveModelSerializers::SerializableResource.new(SalaryElement.first).as_json
    assert_not_nil display_template
  end
end
