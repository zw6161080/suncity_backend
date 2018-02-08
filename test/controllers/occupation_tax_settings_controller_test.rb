require 'test_helper'

class OccupationTaxSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OccupationTaxSetting.load_predefined
    @occupation_tax_setting = OccupationTaxSetting.first
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :salary_calculate_setting, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  # test "should create occupation_tax_setting" do
  #   assert_difference('OccupationTaxSetting.count', 0) do
  #     post occupation_tax_settings_url, params: {
  #       occupation_tax_setting: {
  #         deduct_percent: @occupation_tax_setting.deduct_percent,
  #         favorable_percent: @occupation_tax_setting.favorable_percent,
  #         ranges: @occupation_tax_setting.ranges
  #       }
  #     }, as: :json
  #   end
  #
  #   assert_response 201
  # end

  test "should show occupation_tax_setting" do
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    get occupation_tax_settings_url, as: :json
    assert_response 403
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    get occupation_tax_settings_url, as: :json
    assert_response :success
    setting = json_res
    assert %w(deduct_percent favorable_percent ranges).to_set.subset? setting.keys.to_set
    assert setting['ranges'].is_a? Array
    assert setting['ranges'].all? { |r| r.has_key?('limit') && r.has_key?('tax_rate') }
  end

  test "should reset occupation tax setting" do
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    patch reset_occupation_tax_settings_url, as: :json
    assert_response 403
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    patch reset_occupation_tax_settings_url, as: :json
    assert_response :success
  end

  test "should update occupation_tax_setting" do
    update_params = {
      'deduct_percent' => '20.0',
      'favorable_percent' => '10.0',
      'ranges' => [
        { 'limit' => '10000.0', 'tax_rate' => '10.00' },
        { 'limit' => nil, 'tax_rate' => '30.00' },
      ]
    }
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    patch occupation_tax_settings_url, params: {
      occupation_tax_setting: update_params
    }, as: :json

    assert_response 403
    OccupationTaxSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    patch occupation_tax_settings_url, params: {
      occupation_tax_setting: update_params
    }, as: :json

    assert_response 200

    @occupation_tax_setting.reload
    assert_equal BigDecimal.new(update_params['deduct_percent']), @occupation_tax_setting.deduct_percent
    assert_equal BigDecimal.new(update_params['favorable_percent']), @occupation_tax_setting.favorable_percent
    assert @occupation_tax_setting.ranges.is_a? Array
    @occupation_tax_setting.ranges.each_with_index do |val, index|
      assert_equal update_params['ranges'][index]['limit'], val['limit']
      assert_equal update_params['ranges'][index]['tax_rate'], val['tax_rate']
    end
  end

  # test "should destroy occupation_tax_setting" do
  #   assert_difference('OccupationTaxSetting.count', -1) do
  #     delete occupation_tax_settings_url, as: :json
  #   end
  #
  #   assert_response 204
  # end
end
