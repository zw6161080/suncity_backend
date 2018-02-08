# coding: utf-8
require "test_helper"

class EmployeePreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile = create_profile
    @user = profile.user

    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @class_setting = create(:class_setting)

    @user.location_id = @location.id
    @user.department_id = @department.id
    @user.position_id = @position.id
    @user.save

    @location.department_ids = [@department.id]
    @location.position_ids = [@position.id]
    @location.save

    @department.position_ids = [@position.id]
    @department.save

    @class_setting.department_id = @department.id
    @class_setting.save
  end

  test "should get index & update" do
    RosterPreference.initial_table
    roster_p = RosterPreference.first

    get "/roster_preferences/#{roster_p.id}/employee_preferences"
    assert_response :success
    p = json_res['data'].first

    byebug

    update_roster_params = {
      employee_roster_preferences: [
        {
          user_id: p['user_id'],
          employee_preference_id: p['id'],
          date_range: '2017/01/01~2017/02/01',
          class_setting_group: [@class_setting.id],
        }
      ]
    }

    patch "/roster_preferences/#{roster_p.id}/employee_preferences/#{p['id']}/set_employee_roster_preferences", params: update_roster_params
    assert_response :success

    update_general_holiday_params = {
      employee_general_holiday_preferences: [
        {
          user_id: p['user_id'],
          employee_preference_id: p['id'],
          date_range: '2017/01/01~2017/02/01',
          day_group: [1, 2],
        }
      ]
    }

    patch "/roster_preferences/#{roster_p.id}/employee_preferences/#{p['id']}/set_employee_general_holiday_preferences", params: update_general_holiday_params
    assert_response :success

    get "/roster_preferences/#{roster_p.id}/employee_preferences"
    assert_response :success
    p = json_res['data'].first

    byebug
  end
end
