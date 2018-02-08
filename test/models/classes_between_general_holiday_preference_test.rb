require "test_helper"

class ClassesBetweenGeneralHolidayPreferenceTest < ActiveSupport::TestCase
  def classes_between_general_holiday_preference
    @classes_between_general_holiday_preference ||= ClassesBetweenGeneralHolidayPreference.new
  end

  def test_valid
    assert classes_between_general_holiday_preference.valid?
  end
end
