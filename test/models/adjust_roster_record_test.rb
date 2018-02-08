require "test_helper"

class AdjustRosterRecordTest < ActiveSupport::TestCase
  def adjust_roster_record
    @adjust_roster_record ||= AdjustRosterRecord.new
  end

  def test_valid
    assert adjust_roster_record.valid?
  end
end
