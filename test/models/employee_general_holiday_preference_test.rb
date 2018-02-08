require "test_helper"

class EmployeeGeneralHolidayPreferenceTest < ActiveSupport::TestCase
  def employee_general_holiday_preference
    @employee_general_holiday_preference ||= EmployeeGeneralHolidayPreference.new
  end

  def test_valid
    assert employee_general_holiday_preference.valid?
  end
end
