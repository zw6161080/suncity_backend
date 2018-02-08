# coding: utf-8
require "test_helper"

class RosterModelsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @class_setting = create(:class_setting, id: 1)
    # @roster_object = create(:roster_object, class_setting_id: @class_setting.id)
    @department = create(:department, chinese_name: '行政及人力資源部')
    test_user = create_test_user
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    test_user.add_role(admin_role)
    RosterModelsController.any_instance.stubs(:current_user).returns(test_user)
  end

  test "should get index" do
    create(:roster_model, department_id: @department.id)

    params = {
      region: 'macau'
    }

    get '/roster_models', params: params
    assert_response :success
  end

  test "create & update & destroy" do
    params = {
      region: 'macau',
      chinese_name: 'chinese_name',
      department_id: @department.id,
      start_date: '2017/09/03',
      end_date: '2017/09/30',
      weeks_count: 2,
      roster_model_weeks: [
        {
          order_no: 1,
          mon_class_setting_id: @class_setting.id,
          tue_class_setting_id: @class_setting.id,
          wed_class_setting_id: @class_setting.id,
          thu_class_setting_id: @class_setting.id,
          fri_class_setting_id: @class_setting.id,
          sat_class_setting_id: nil,
          sun_class_setting_id: nil,
        },
        {
          order_no: 2,
          mon_class_setting_id: @class_setting.id,
          tue_class_setting_id: @class_setting.id,
          wed_class_setting_id: @class_setting.id,
          thu_class_setting_id: @class_setting.id,
          fri_class_setting_id: @class_setting.id,
          sat_class_setting_id: nil,
          sun_class_setting_id: nil,
        }
      ]
    }

    post '/roster_models', params: params, as: :json
    assert_response :ok

    params = {
      region: 'macau'
    }

    get '/roster_models'
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 2, json_res['data'].first['roster_model_weeks'].count

    roster_m = json_res['data'].first

    byebug

    update_params = {
      region: 'macau',
      chinese_name: 'chinese_name',
      department_id: @department.id,
      start_date: '2017/09/03',
      end_date: '2017/09/30',
      weeks_count: 2,
      roster_model_weeks: [
        {
          order_no: 1,
          mon_class_setting_id: @class_setting.id,
          tue_class_setting_id: @class_setting.id,
          wed_class_setting_id: @class_setting.id,
          thu_class_setting_id: @class_setting.id,
          fri_class_setting_id: nil,
          sat_class_setting_id: nil,
          sun_class_setting_id: nil,
        },
        {
          order_no: 2,
          mon_class_setting_id: @class_setting.id,
          tue_class_setting_id: @class_setting.id,
          wed_class_setting_id: @class_setting.id,
          thu_class_setting_id: @class_setting.id,
          fri_class_setting_id: nil,
          sat_class_setting_id: nil,
          sun_class_setting_id: nil,
        }
      ]
    }

    # update
    patch "/roster_models/#{roster_m['id']}", params: update_params
    assert_response :success

    get '/roster_models'
    assert_response :success
    assert_equal nil, json_res['data'].first['roster_model_weeks'].first['fri_class_setting_id']

    # delete
    delete "/roster_models/#{roster_m['id']}"
    assert_response :success

    get '/roster_models'
    assert_response :success

    assert_equal 0, json_res['data'].count
  end
end
