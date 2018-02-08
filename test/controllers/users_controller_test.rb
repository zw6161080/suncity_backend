require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(100)
    create_test_user(101)
    @current_user = User.find(100)
    @another_user = User.find(101)
    UsersController.any_instance.stubs(:current_user).returns(@current_user)
    current_user = create(:user)
    UsersController.any_instance.stubs(:current_user).returns(current_user)
    UsersController.any_instance.stubs(:authorize).returns(true)
  end

  test 'get user roles' do
    user = create(:user)

    get "/users/#{user.id}/roles"
    assert_response :ok
  end

  test 'post add user role and remove user role' do
    user = create(:user)
    role1 = create(:role)
    role2 = create(:role)
    params = {
      role_ids: [ role1.id, role2.id ]
    }
    
    assert_difference('user.roles.count', 2) do
      post "/users/#{user.id}/add_role", params: params, as: :json
      assert_response :ok
    end

    params = {
      role_id: role1.id
    }

    assert_difference('user.roles.count', -1) do
      post "/users/#{user.id}/remove_role", params: params
      assert_response :ok
    end
  end

  test 'get user permissions' do
    user = create(:user)
    role = create(:role)
    user.add_role(role)
    role.add_permission_by_attribute(:admin, :global, :macau)

    get "/users/#{user.id}/permissions"
    assert_response :ok
  end

  test 'get user group by position_id' do
    create(:position, id: 10, chinese_name: '網絡及系統副總監')
    create(:position, id: 12,chinese_name: '總監')
    User.first.update(position_id: 12)
    User.first.update(grade: 3)
    create(:user).update(position_id: 12)
    create(:user).update(position_id: 10)
    create(:user).update(position_id: 10)
    get "/users/get_user_group_by_position_id"
    assert json_res.is_a? Hash
    data_is_legal = 1
    json_res.keys.each { |k| data_is_legal = 0 if k == nil }
    assert_equal(1,  data_is_legal)
    assert_response :ok
  end
end
