require "test_helper"

class RosterPreferenceTest < ActiveSupport::TestCase
  def roster_preference
    @roster_preference ||= RosterPreference.new
  end

  def test_valid
    assert roster_preference.valid?
  end
end
