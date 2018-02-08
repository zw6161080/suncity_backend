require 'test_helper'

class BonusElementSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    location_a = create(:location)
    location_a.departments << create(:department)
    location_a.departments << create(:department)
    location_a.departments << create(:department)
    location_a.save

    BonusElement.load_predefined

    @bonus_element_setting = BonusElementSetting.first
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :salary_calculate_setting, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    get bonus_element_settings_url, as: :json
    assert_response 403
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    get bonus_element_settings_url, as: :json
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? do |element|
      %w(department_id location_id bonus_element_id value).all? { |key| element[key].present? }
    end
  end

  # test "should create bonus_element_setting" do
  #   assert_difference('BonusElementSetting.count') do
  #     post bonus_element_settings_url, params: { bonus_element_id: @bonus_element_setting.bonus_element_id, department_id: @bonus_element_setting.department_id, location_id: @bonus_element_setting.location_id, value: @bonus_element_setting.value }, as: :json
  #   end
  #
  #   assert_response 201
  # end

  # test "should show bonus_element_setting" do
  #   get bonus_element_setting_url(@bonus_element_setting), as: :json
  #   assert_response :success
  # end

  test "should update bonus_element_setting" do
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    patch bonus_element_setting_url(@bonus_element_setting), params: { bonus_element_id: @bonus_element_setting.bonus_element_id, department_id: @bonus_element_setting.department_id, location_id: @bonus_element_setting.location_id, value: @bonus_element_setting.value }, as: :json
    assert_response 403
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    patch bonus_element_setting_url(@bonus_element_setting), params: { bonus_element_id: @bonus_element_setting.bonus_element_id, department_id: @bonus_element_setting.department_id, location_id: @bonus_element_setting.location_id, value: @bonus_element_setting.value }, as: :json
    assert_response 200
  end

  test "should reset bonus element setting" do
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    patch reset_bonus_element_settings_url, as: :json
    assert_response 403
    BonusElementSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    patch reset_bonus_element_settings_url, as: :json
    assert_response :success
  end

  # test "should batch update bonus_element_setting" do
  #   first_setting = BonusElementSetting.first
  #   last_setting = BonusElementSetting.last
  #   first_update = { bonus_element_id: first_setting.bonus_element_id, department_id: first_setting.department_id, location_id: first_setting.location_id, value: :personal }
  #   last_update = { bonus_element_id: last_setting.bonus_element_id, department_id: last_setting.department_id, location_id: last_setting.location_id, value: :personal }
  #   patch batch_update_bonus_element_settings_url, params: { updates: [ first_update, last_update ] }
  #   assert_response :success
  #   first_setting.reload
  #   last_setting.reload
  #   assert_equal first_setting.value, 'personal'
  #   assert_equal last_setting.value, 'personal'
  # end

  # test "should destroy bonus_element_setting" do
  #   assert_difference('BonusElementSetting.count', -1) do
  #     delete bonus_element_setting_url(@bonus_element_setting), as: :json
  #   end
  #
  #   assert_response 204
  # end
end
