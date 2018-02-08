require "test_helper"

class EmployeePreferenceTest < ActiveSupport::TestCase
  def employee_preference
    @employee_preference ||= EmployeePreference.new
  end

  def test_valid
    assert employee_preference.valid?
  end
end
