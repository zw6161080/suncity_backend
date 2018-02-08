require "test_helper"

class AttendLogTest < ActiveSupport::TestCase
  def attend_log
    @attend_log ||= AttendLog.new
  end

  def test_valid
    assert attend_log.valid?
  end
end
