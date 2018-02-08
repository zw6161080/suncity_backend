# coding: utf-8
require "test_helper"

class TyphoonSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile = create_profile
    @user = profile.user
    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = @location.id
    @user.department_id = @department.id
    @user.position_id = @position.id
    @user.save

    @class_setting = create(:class_setting, start_time: '12:00:00', end_time: '15:00:00')
    @roster_object = create(:roster_object, class_setting_id: @class_setting.id)
    @attend = create(:attend, roster_object_id: @roster_object.id, attend_date: '2017/03/01', user_id: @user.id)
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :TyphoonSetting, :macau)
    @user.add_role(admin_role)
    TyphoonSettingsController.any_instance.stubs(:current_user).returns(@user)
  end

  test "should get index" do
    create(:typhoon_setting)

    params = {
      region: 'macau'
    }

    get '/typhoon_settings', params: params
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    byebug
  end

  test "typhoon_settings( create & update & destroy) AND typhoon_qualified_records(index, do_apply, cancel_apply)" do
    params = {
      #start_date: '2017/03/02',
      end_date: '2017/03/03',
      start_time: '09:00',
      end_time: '21:00'
    }

    # typhoon_setting create
    post "/typhoon_settings", params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    params = {
        start_date: '2016/03/02',
        end_date: '2017/03/03',
        start_time: '09:00',
        end_time: '21:00'
    }

    # typhoon_setting create
    post "/typhoon_settings", params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'

    params = {
        start_date: '2017/03/02',
        end_date: '2017/03/03',
        start_time: '22:00',
        end_time: '21:00'
    }

    # typhoon_setting create
    post "/typhoon_settings", params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'

    params = {
        start_date: '2017/03/02',
        end_date: '2017/03/03',
        start_time: '09:00',
        end_time: '21:00'
    }

    # typhoon_setting create
    post "/typhoon_settings", params: params, as: :json
    assert_response :ok

    get '/typhoon_settings'
    assert_response :success

    # typhoon_setting update
    ts = json_res['data'].first

    update_params = {
      start_date: '2017/03/01',
      end_date: '2017/03/03',
      start_time: '08:00',
      end_time: '23:00'
    }

    patch "/typhoon_settings/#{ts['id']}", params: update_params, as: :json
    assert_response :success

    get '/typhoon_settings'
    assert_response :success
    byebug

    # typhoon_qualified_records index
    get '/typhoon_qualified_records'
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    byebug

    # typhoon_qualified_records do_apply
    tqr = json_res['data'].first
    patch "/typhoon_qualified_records/#{tqr['id']}/do_apply"

    get '/typhoon_qualified_records'
    assert_response :success
    assert_equal 1, json_res['data'].count
    byebug

    get '/typhoon_settings'
    assert_response :success
    byebug

    # typhoon_setting delete: cannot be deleted here
    delete "/typhoon_settings/#{ts['id']}"
    assert_response :success

    get '/typhoon_settings'
    assert_response :success

    assert_equal 1, json_res['data'].count
    byebug

    # typhoon_qualified_records cancel_apply
    patch "/typhoon_qualified_records/#{tqr['id']}/cancel_apply"

    get '/typhoon_qualified_records'
    assert_response :success
    assert_equal 1, json_res['data'].count
    byebug

    get '/typhoon_settings'
    assert_response :success
    byebug

    # typhoon_setting delete: cannot be deleted here
    delete "/typhoon_settings/#{ts['id']}"
    assert_response :success

    get '/typhoon_settings'
    assert_response :success

    assert_equal 0, json_res['data'].count
    byebug
  end
end
