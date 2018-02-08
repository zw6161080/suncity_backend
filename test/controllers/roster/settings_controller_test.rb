require 'test_helper'

class Roster::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @roster = rostered_roster
  end

  test "post create setting" do
    position_setting = {}
    @roster.department.positions.pluck(:id).each do |pid|
      position_setting[pid] = rand(10)
    end

    params = {
      shift_interval_hour: position_setting,
      rest_number: position_setting,
      rest_interval_day: position_setting,
      shift_type_number: position_setting
    }

    assert_difference('RosterSetting.count', 1) do
      post "/rosters/#{@roster.id}/settings", params: params, as: :json
      assert_response :ok
      setting = RosterSetting.last

      position_setting_string_keys = position_setting.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
      assert_equal position_setting_string_keys, setting.shift_interval_hour
      assert_equal position_setting_string_keys, setting.rest_number
      assert_equal position_setting_string_keys, setting.rest_interval_day
      assert_equal position_setting_string_keys, setting.shift_type_number
    end
  end
end
