require "test_helper"

class EmployeeRosterPreferenceTest < ActiveSupport::TestCase
  def employee_roster_preference
    @employee_roster_preference ||= EmployeeRosterPreference.new
  end

  def test_valid
    assert employee_roster_preference.valid?
  end
end
