require "test_helper"

class RosterModelWeekTest < ActiveSupport::TestCase
  def roster_model_week
    @roster_model_week ||= RosterModelWeek.new
  end

  def test_valid
    assert roster_model_week.valid?
  end
end
