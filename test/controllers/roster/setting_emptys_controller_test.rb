require 'test_helper'

class Roster::SettingEmptysControllerTest < ActionDispatch::IntegrationTest
  test "清空Roster设置接口" do
    roster = create(:roster)
    roster.shift_interval = {"1" => 2, "3" => 4}
    roster.save

    post "/rosters/#{roster.id}/setting_emptys"
    assert_response :ok
    roster.reload
    assert_nil roster.shift_interval
  end
end
