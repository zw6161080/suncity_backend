require "test_helper"

class RosterObjectLogTest < ActiveSupport::TestCase
  def roster_object_log
    @roster_object_log ||= RosterObjectLog.new
  end

  def test_valid
    assert roster_object_log.valid?
  end
end
