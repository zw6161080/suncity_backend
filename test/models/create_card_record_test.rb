require "test_helper"

class CreateCardRecordTest < ActiveSupport::TestCase
  def create_card_record
    @create_card_record ||= CreateCardRecord.new
  end

  def test_valid
    assert create_card_record.valid?
  end
end
