require "test_helper"

class EntryWaitedRecordTest < ActiveSupport::TestCase
  def entry_waited_record
    @entry_waited_record ||= EntryWaitedRecord.new
  end

  def test_valid
    assert entry_waited_record.valid?
  end
end
