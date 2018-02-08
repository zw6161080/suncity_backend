require "test_helper"

class RosterIntervalPreferenceTest < ActiveSupport::TestCase
  def roster_interval_preference
    @roster_interval_preference ||= RosterIntervalPreference.new
  end

  def test_valid
    assert roster_interval_preference.valid?
  end
end
