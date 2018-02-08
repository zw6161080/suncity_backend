require 'test_helper'

class PunchLogsControllerTest < ActionDispatch::IntegrationTest
  test "get index" do
    user = create(:user, empoid: 88010022)
    logs = RosterEventLogV2.of_user_date(user, Time.zone.local(2018, 1, 2).to_datetime)
    get '/punch_logs', params: {user_id: user.id, date: '2018-1-2'}

    assert logs.length, json_res['data'].length
  end
end
