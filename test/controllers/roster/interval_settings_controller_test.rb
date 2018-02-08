require 'test_helper'

class Roster::IntervalSettingsControllerTest < ActionDispatch::IntegrationTest
  test "设定排班表的排班相隔时间" do
    roster = create(:roster)
    type = 'shift_interval'

    patch "/rosters/#{roster.id}/interval_settings/#{type}", params: {
      grade: '1',
      value: '2'
    }

    assert_response :ok
    roster.reload

    assert_equal 2, roster.shift_interval["1"]
  end

  test "错误的类型" do
    roster = create(:roster)
    type = 'shift_interval1'

    patch "/rosters/#{roster.id}/interval_settings/#{type}", params: {
      grade: '1',
      value: '2'
    }

    assert_response 422
  end
end
