require 'test_helper'

class OccupationTaxSettingTest < ActiveSupport::TestCase
  test "load predefined setting" do
    OccupationTaxSetting.load_predefined
    OccupationTaxSetting.load_predefined

    assert_equal 1, OccupationTaxSetting.count
    setting = OccupationTaxSetting.first
    assert_not_nil setting.deduct_percent
    assert_not_nil setting.favorable_percent
    assert setting.ranges.is_a? Array
    assert setting.ranges.all? { |r| r.has_key?('limit') && r.has_key?('tax_rate') }
    assert_nil setting.ranges.last['limit']
  end
end
