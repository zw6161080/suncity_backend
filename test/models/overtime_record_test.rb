require "test_helper"

class OvertimeRecordTest < ActiveSupport::TestCase
  def overtime_record
    @overtime_record ||= OvertimeRecord.new
  end

  def test_valid
    assert overtime_record.valid?
  end
end
