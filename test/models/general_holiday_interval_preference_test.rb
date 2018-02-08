require "test_helper"

class GeneralHolidayIntervalPreferenceTest < ActiveSupport::TestCase
  def general_holiday_interval_preference
    @general_holiday_interval_preference ||= GeneralHolidayIntervalPreference.new
  end

  def test_valid
    assert general_holiday_interval_preference.valid?
  end
end
