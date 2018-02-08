# coding: utf-8
require "test_helper"

class RosterListsControllerTest < ActionDispatch::IntegrationTest
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
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    admin_role.add_permission_by_attribute(:view_for_search, :RosterList, :macau)
    @user.add_role(admin_role)
    RosterListsController.any_instance.stubs(:current_user).returns(@user)
  end

  test "should get index" do
    create(:roster_list, location_id: @location.id, department_id: @department.id)

    params = {
      region: 'macau'
    }

    get '/roster_lists', params: params
    assert_response :success
    byebug

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    params_2 = {
      location_id: 0,
    }

    get '/roster_lists', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    roster_list = create(:roster_list, location_id: @location.id, department_id: @department.id)

    get "/roster_lists/#{roster_list.id}", as: :json
    assert_response :ok
    byebug
  end

  test "create & destroy" do
    params = {
      region: 'macau',
      chinese_name: 'chinese_name',
      english_name: 'english_name',
      simple_chinese_name: 'simple_chinese_name',
      location_id: @location.id,
      department_id: @department.id,
      date_range: '2017/01/01~2017/02/01',
      creator: @user.id,
    }

    post '/roster_lists', params: params, as: :json
    assert_response :ok

    get '/roster_lists'
    assert_response :success


    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    rl = json_res['data'].first
    get "/roster_lists/#{rl['id']}", as: :json
    assert_response :ok

    delete "/roster_lists/#{rl['id']}"
    assert_response :ok

    get '/roster_lists'

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "to draft" do
    roster_list = create(:roster_list, location_id: @location.id, department_id: @department.id, status: 1)

    patch "/roster_lists/#{roster_list.id}/to_draft", as: :json
    assert_response :ok
    byebug

    get "/roster_lists/#{roster_list.id}", as: :json
    assert_response :success

    assert_equal 'is_draft', json_res['data']['status']
  end

  test "to public" do
    roster_list = create(:roster_list, location_id: @location.id, department_id: @department.id, status: 0)

    patch "/roster_lists/#{roster_list.id}/to_public", as: :json
    assert_response :ok

    get "/roster_lists/#{roster_list.id}", as: :json
    assert_response :success

    assert_not_equal 'is_public', json_res['data']['status']
  end

  test "to sealed" do
    roster_list = create(:roster_list, location_id: @location.id, department_id: @department.id, status: 0)

    patch "/roster_lists/#{roster_list.id}/to_sealed", as: :json
    assert_response :ok

    get "/roster_lists/#{roster_list.id}", as: :json
    assert_response :success

    assert_not_equal 'is_sealed', json_res['data']['status']
  end

  test "get roster_objects" do
    params = {
      region: 'macau',
      chinese_name: 'chinese_name',
      english_name: 'english_name',
      simple_chinese_name: 'simple_chinese_name',
      location_id: @location.id,
      department_id: @department.id,
      date_range: '2017/01/01~2017/01/10',
      creator: @user.id,
    }

    post '/roster_lists', params: params, as: :json
    assert_response :ok

    get '/roster_lists'
    assert_response :success


    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    rl = json_res['data'].first

    get "/roster_lists/#{rl['id']}/roster_objects", as: :json
    assert_response :success
    byebug
  end

  test "query roster objects" do
    params = {
      region: 'macau',
      chinese_name: 'chinese_name',
      english_name: 'english_name',
      simple_chinese_name: 'simple_chinese_name',
      location_id: @location.id,
      department_id: @department.id,
      date_range: '2017/01/01~2017/01/10',
      creator: @user.id,
    }

    post '/roster_lists', params: params, as: :json
    assert_response :ok

    get '/roster_lists'
    assert_response :success


    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    rl = json_res['data'].first

    get "/roster_lists/#{rl['id']}/roster_objects"
    assert_response :success

    query_params = {
      location_id: @location.id,
      department_id: @department.id,
    }

    get "/roster_lists/query_roster_objects", params: query_params
    assert_response :success
    assert_equal 1, json_res['meta']['total_count']

    patch "/roster_lists/#{rl['id']}/to_public"

    get "/roster_lists/query_roster_objects", params: query_params
    assert_response :success
    assert_equal 1, json_res['meta']['total_count']

    byebug
  end

  test "should get options" do
    create(:roster_list, location_id: @location.id, department_id: @department.id)

    get "/roster_lists/options", as: :json
    assert_response :ok

    byebug
  end
end
