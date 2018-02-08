require 'test_helper'

class Roster::DaysControllerTest < ActionDispatch::IntegrationTest
  test '获取排班表的有效日期' do
    location = create(:location, id: 1)
    roster = create(:roster, location_id: location.id)

    get "/rosters/#{roster.id}/days"
    assert_response :ok
    assert_equal roster.availability.to_a.count, json_res['data'].length
  end
end
