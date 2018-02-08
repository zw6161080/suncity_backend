# coding: utf-8
require "test_helper"

class RosterModelStatesControllerTest < ActionDispatch::IntegrationTest
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

    @roster_model = create(:roster_model)
    @class_setting = create(:class_setting, id: 1)
    @roster_model_week = create(:roster_model_week,
                                order_no: 1,
                                roster_model_id: @roster_model.id,
                                mon_class_setting_id: @class_setting.id,
                                tue_class_setting_id: @class_setting.id,
                                wed_class_setting_id: @class_setting.id,
                                thu_class_setting_id: @class_setting.id,
                                fri_class_setting_id: @class_setting.id,
                                sat_class_setting_id: nil,
                                sun_class_setting_id: nil,
                               )
  end

  test "get user_roster_models_info" do
    3.times do |i|
      # roster_model = create(:roster_model, chinese_name: "#{i} model", department_id: @department.id, start_date: "2017/01/01", end_date: "201#{8 + i}/01/01")
      create(:roster_model_state, user_id: @user.id, start_date: "2017/0#{i + 1}/02", roster_model_id: @roster_model.id)
    end

    params = {
      location_id: @location.id,
      department_id: @department.id,
      start_date: '2017/01/15',
      end_date: '2017/03/25',
    }

    get "/roster_model_states/user_roster_models_info", params: params
    assert_response :success
    assert_equal 3, json_res['data'].first['roster_model_states'].count

    byebug
  end

  test "create" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_response :success
    byebug
  end

  test "create with end" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      end_date: '2018/01/21',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_response :success
    assert_equal 2, RosterModelState.first.current_week_no
    byebug
  end

  test "create with next" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/21',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_response :success

    params_2 = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      start_week_no: 1
    }

    post "/roster_model_states", params: params_2, as: :json

    assert_equal 2, RosterModelState.second.current_week_no
    byebug
  end

  test "update" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      end_date: '2018/01/31',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_equal 3, RosterModelState.first.current_week_no
    assert_response :success

    params_2 = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/19',
      end_date: '2018/01/31',
      start_week_no: 1
    }

    patch "/roster_model_states/#{RosterModelState.first.id}", params: params_2, as: :json

    assert_response :success
    assert_equal 2, RosterModelState.first.current_week_no
    byebug
  end

  test "destroy" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      end_date: '2018/01/31',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_response :success

    delete "/roster_model_states/#{RosterModelState.first.id}"

    assert_response :success
    assert_equal 0, RosterModelState.all.count
    byebug
  end

  test "index" do
    params = {
      user_id: @user.id,
      roster_model_id: @roster_model.id,
      start_date: '2018/01/12',
      end_date: '2018/01/31',
      start_week_no: 1
    }

    post "/roster_model_states", params: params, as: :json
    assert_response :success

    index_params = {
      user_id: @user.id,
    }

    get "/roster_model_states", params: index_params

    assert_response :success
    byebug
  end
end
