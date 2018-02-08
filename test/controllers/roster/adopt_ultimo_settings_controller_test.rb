require 'test_helper'

class Roster::AdoptUltimoSettingsControllerTest < ActionDispatch::IntegrationTest
  test "沿用上月规则接口" do
    department = create(:department)
    location = create(:location)
    old_roster = create(:roster, department_id: department.id, location_id: location.id)

    3.times do
      old_roster.shifts << create(:shift, roster_id: old_roster.id)
      old_roster.shift_groups << create(:shift_group, roster_id: old_roster.id)
    end

    roster = create(:roster, department_id: old_roster.department_id, location_id: old_roster.location_id)

    assert_difference(['Shift.count', 'ShiftGroup.count'], 3) do
      post "/rosters/#{roster.id}/adopt_ultimo_settings"

      assert_response :ok
    end
  end

end
