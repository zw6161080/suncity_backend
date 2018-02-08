require 'test_helper'

class PermissionsControllerTest < ActionDispatch::IntegrationTest

  # test "get permissions" do
  #   get "/permissions"

  #   assert_equal json_res['data'].length, Permission.policies.reduce(0){|l, actions| l += actions.first.last.length }
  #   assert_response :ok
  # end

  # test "get one permission" do
  #   permission = create(:permission)

  #   get "/permissions/#{permission.id}"
  #   assert_response :ok
  # end

  # test "patch update permission" do
  #   permission = create(:permission)

  #   assert_difference('Permission.count', 0) do
  #     patch "/permissions/#{permission.id}", params: { chinese_name: 'chinese_name_test' }
  #     assert_response :ok
  #   end
  # end

  test 'get policies' do
    get "/policies"
    assert_equal json_res['data'].length, 56

    get "/policies?with_translations=1"
    assert_equal json_res['data'].length, 56
  end
end
