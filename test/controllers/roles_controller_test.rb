require 'test_helper'

class RolesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @profile = create_profile
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:admin, :global, :macau)
    @current_user.add_role(@admin_role)
    @profile.user = @current_user

    RolesController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test 'get roles list' do
    10.times do
      create(:role)
    end

    get '/roles'
    assert_response :ok
    assert_equal 11, json_res['data'].count
  end

  test 'get show one role' do
    the_role = create(:role, chinese_name: 'chinese_name_test')

    get "/roles/#{the_role.id}"
    assert_response :ok
    assert_equal json_res['data'].fetch('chinese_name'), 'chinese_name_test'
  end

  test 'get roles of current user' do
    10.times do
      create(:role)
    end

    roles = []
    7.times do
      roles << create(:role)
    end

    current_user = create(:user)
    current_user.roles << roles
    RolesController.any_instance.stubs(:current_user).returns(current_user)

    get "/roles/mine"
    assert_response :ok
    assert_equal json_res['data'].count, 7
  end

  test 'post create role' do
    params = {
      chinese_name: '角色组名－test'
    }

    assert_difference('Role.count', 1) do
      post '/roles', params: params
      assert_response :ok
      assert_equal Role.last.chinese_name, params[:chinese_name]
    end
  end

  test 'patch update role' do
    params = {
      chinese_name: '角色组名－test-new'
    }

    the_role = create(:role, chinese_name: 'chinese_name_test')

    assert_difference('Role.count', 0) do
      patch "/roles/#{the_role.id}", params: params
      assert_response :ok
      the_role.reload
      assert_equal the_role.chinese_name, '角色组名－test-new'
    end
  end


  test 'destroy role' do
    params = {
      chinese_name: '角色组名－test-new'
    }

    the_role = create(:role)

    assert_difference('Role.count', -1) do
      delete "/roles/#{the_role.id}"
      assert_response :ok
    end
  end

  test 'add permission and remove permission' do
    params = {
      permissions: [
        { action: 'test action', resource: 'test resource', region: 'macau'},
        { action: 'test action2', resource: 'test resource2', region: 'macau'}
      ]
    }

    the_role = create(:role)

    assert_difference('the_role.permissions.count', 2) do
      post "/roles/#{the_role.id}/add_permission", params: params, as: :json
      assert_response :ok
    end

    assert_difference('the_role.permissions.count', -2) do
      delete "/roles/#{the_role.id}/remove_permission", params: {permission_ids: the_role.permissions.pluck(:id)}
      assert_response :ok
    end
  end

  test 'add users and remove users' do

    params = {
      user_ids: [
        create(:user, email: 'user_1@test.con').id,
        create(:user, email: 'user_2@test.con').id
      ]
    }

    the_role = create(:role)

    assert_difference('the_role.users.count', 2) do
      post "/roles/#{the_role.id}/add_user", params: params, as: :json
      assert_equal json_res['data'].length, 2
      assert_response :ok
    end

    assert_difference('the_role.users.count', -2) do
      delete "/roles/#{the_role.id}/remove_user", params: {user_ids: the_role.users.pluck(:id)}
      assert_response :ok
    end
  end

end
