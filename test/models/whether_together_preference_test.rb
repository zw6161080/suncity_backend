require "test_helper"

class WhetherTogetherPreferenceTest < ActiveSupport::TestCase
  def whether_together_preference
    @whether_together_preference ||= WhetherTogetherPreference.new
  end

  def test_valid
    assert whether_together_preference.valid?
  end
end
