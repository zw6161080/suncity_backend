require 'test_helper'

class Roster::AvailableDepartmentsControllerTest < ActionDispatch::IntegrationTest
  test "获取某月可以创建排班表的部门" do
    10.times do
      create(:department)
    end

    region = Department.first.region

    get '/rosters/available_departments', params: {
      region: region,
      year: Time.zone.now.year,
      month: Time.zone.now.month,
    }

    assert_response :ok
    assert_equal Department.count, json_res['data'].length

    roster = create(:roster)
    assert_equal Department.count - 1, json_res['data'].length
  end
end
