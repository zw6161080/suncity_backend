# coding: utf-8
require "test_helper"

class RosterPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    profile = create_profile
    @user = profile.user

    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @class_setting = create(:class_setting)

    @location.department_ids = [@department.id]
    @location.position_ids = [@position.id]
    @location.save

    @department.position_ids = [@position.id]
    @department.save

    @class_setting.department_id = @department.id
    @class_setting.save

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :RosterPreference, :macau)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    @user.add_role(admin_role)
    RosterPreferencesController.any_instance.stubs(:current_user).returns(@user)
  end

  test "should get index & show" do
    params = {
      region: 'macau'
    }

    get '/roster_preferences', params: params
    assert_response :success

    p = json_res['data'].first

    get "/roster_preferences/#{p['id']}", params: params
    assert_response :success

    update_params = {
      latest_updater_id: @user.id,
      class_people_preferences: [
        {
          class_setting_id: @class_setting.id,
          max_of_total: 999,
          min_of_total: 99,
          max_of_manager_level: 999,
          min_of_manager_level: 99,
          max_of_director_level: 999,
          min_of_director_level: 99,
        },

        {
          class_setting_id: nil,
          max_of_total: 999,
          min_of_total: 99,
          max_of_manager_level: 999,
          min_of_manager_level: 99,
          max_of_director_level: 999,
          min_of_director_level: 99,
        }
      ],

      roster_interval_preferences: [
        {
          position_id: @position.id,
          interval_hours: 10,
        }
      ],

      general_holiday_interval_preferences: [
        {
          position_id: @position.id,
          max_interval_days: 10,
        }
      ],

      classes_between_general_holiday_preferences: [
        {
          position_id: @position.id,
          max_classes_count: 19,
        }
      ],

      whether_together_preferences: [
        {
          group_name: 'g_name 1',
          date_range: '2017/01/01~2017/02/01',
          comment: 'comment 1',
          is_together: true,
        },

        {
          group_name: 'g_name 2',
          date_range: '2017/02/01~2017/03/01',
          comment: 'comment 2',
          is_together: false,
        }
      ]
    }

    patch "/roster_preferences/#{p['id']}", params: update_params
    assert_response :success


    get "/roster_preferences/#{p['id']}", params: params
    assert_response :success
  end

  def test_update
    update_params = {
        latest_updater_id: @user.id,
        class_people_preferences: [
            {
                class_setting_id: @class_setting.id,
                max_of_total: 999,
                min_of_total: 99,
                max_of_manager_level: 999,
                min_of_manager_level: 99,
                max_of_director_level: 999,
                min_of_director_level: 99,
            },

            {
                class_setting_id: nil,
                max_of_total: 999,
                min_of_total: 99,
                max_of_manager_level: 999,
                min_of_manager_level: 99,
                max_of_director_level: 999,
                min_of_director_level: 99,
            }
        ],

        roster_interval_preferences: [
            {
                position_id: @position.id,
                interval_hours: 10,
            }
        ],

        general_holiday_interval_preferences: [
            {
                position_id: @position.id,
                max_interval_days: 10,
            }
        ],

        classes_between_general_holiday_preferences: [
            {
                position_id: @position.id,
                max_classes_count: 19,
            }
        ],

        whether_together_preferences: [
            {
                group_name: 'g_name 1',
                date_range: '2017/01/01~2017/02/01',
                comment: 'comment 1',
                is_together: true,
            },

            {
                group_name: 'g_name 2',
                date_range: '2017/02/01~2017/03/01',
                comment: 'comment 2',
                is_together: false,
            }
        ]
    }

    patch "/roster_preferences/#{p['id']}", params: update_params
    assert_response :success
  end

  def test_roster_model_state_setting_filter
    get roster_model_state_setting_filter_roster_preferences_url
    assert_response :success
    assert_equal json_res['data']['departments'].count, 1
    assert_equal json_res['data']['positions'].count, 1
    assert_equal json_res['data']['departments'].first.chinese_name, '行政及人力資源部'
    assert_equal json_res['data']['positions'].first.chinese_name, '網絡及系統副總監'
  end

  def test_employee_roster_model_state_settings
    params = {
        empoid: @user.empoid,
        user: @user.chinese_name,
        department: @department.id,
        position: @position.id,
        date_of_employment: @user.profile['data']['position_information']['field_values']['date_of_employment'],


    }
    get employee_roster_model_state_settings_roster_preferences_url, params: params
    assert_response :success
  end
end
