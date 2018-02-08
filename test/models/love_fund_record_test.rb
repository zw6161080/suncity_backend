require "test_helper"

class LoveFundRecordTest < ActiveSupport::TestCase
  def love_fund_record
    @love_fund_record ||= LoveFundRecord.new
  end

  def test_valid
    assert love_fund_record.valid?
  end
end
