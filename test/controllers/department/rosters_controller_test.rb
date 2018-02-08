require 'test_helper'

class Department::RostersControllerTest < ActionDispatch::IntegrationTest
  test '获取某部门下的排班表列表' do
    roster = create(:roster)
    department = roster.department

    get "/departments/#{department.id}/rosters"
    assert_response :ok
  end
end
