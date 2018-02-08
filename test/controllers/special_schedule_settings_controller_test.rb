require 'test_helper'

class SpecialScheduleSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile1 = create_profile
    profile2 = create_profile
    @user1 = profile1.user
    @user2 = profile2.user
    @location = create(:location, chinese_name: '测试场馆')
    @department = create(:department, chinese_name: '测试部门')
    @user3 = create(:user, chinese_name: '测试员工', department_id: @department.id, location_id: @location.id)
    @special_schedule_setting = create(:special_schedule_setting, user_id: @user1.id,
                                       target_location_id: @location.id,
                                       target_department_id: @department.id,
                                       date_begin: Time.zone.parse('2017/10/01'),
                                       date_end: Time.zone.parse('2017/10/10')
    )
  end

  def test_index
    get special_schedule_settings_url, as: :json
    assert_response :success
    assert_equal json_res['data'].size, 1
  end

  def test_create
    create_params = {
      user_id: @user2.id,
      target_location_id: @location.id,
      target_department_id: @department.id,
      date_begin: Time.zone.parse('2017/10/01'),
      date_end: Time.zone.parse('2017/10/10')
    }
    assert_difference('SpecialScheduleSetting.count') do
      post special_schedule_settings_url, params: create_params
    end
    assert_response 201

    create_params = {
      user_id: @user3.id,
      target_location_id: @location.id,
      target_department_id: @department.id,
      date_begin: Time.zone.parse('2017/10/01'),
      date_end: Time.zone.parse('2017/10/10')
    }
    post special_schedule_settings_url, params: create_params
    assert_response :success
    assert_equal json_res['can_create'], false

    create_params = {
        user_id: @user3.id,
        #target_location_id: @location.id,
        target_department_id: @department.id,
        date_begin: Time.zone.parse('2017/10/01'),
        date_end: Time.zone.parse('2017/10/10')
    }
    post special_schedule_settings_url, params: create_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
  end

  def test_update
    update_params = {
      user_id: @user1.id,
      target_location_id: @location.id,
      target_department_id: @department.id,
      date_begin: Time.zone.parse('2017/10/10'),
      date_end: Time.zone.parse('2017/10/20')
    }
    patch special_schedule_setting_url(@special_schedule_setting), params: update_params
    assert_response 200

    update_params = {
        user_id: @user1.id,
        target_location_id: @location.id,
        target_department_id: @department.id,
        date_begin: Time.zone.parse('2017/10/10'),
        date_end: Time.zone.parse('2017/10/20')
    }
    patch special_schedule_setting_url(@special_schedule_setting), params: update_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
  end

  def test_destroy
    assert_difference('SpecialScheduleSetting.count', -1) do
      delete special_schedule_setting_url(@special_schedule_setting)
    end
    assert_response :success
  end
end
