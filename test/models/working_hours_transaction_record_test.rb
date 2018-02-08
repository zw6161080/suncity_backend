require "test_helper"

class WorkingHoursTransactionRecordTest < ActiveSupport::TestCase
  def working_hours_transaction_record
    @working_hours_transaction_record ||= WorkingHoursTransactionRecord.new
  end

  def test_valid
    assert working_hours_transaction_record.valid?
  end
end
