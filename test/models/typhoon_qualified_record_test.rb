require "test_helper"

class TyphoonQualifiedRecordTest < ActiveSupport::TestCase
  def typhoon_qualified_record
    @typhoon_qualified_record ||= TyphoonQualifiedRecord.new
  end

  def test_valid
    assert typhoon_qualified_record.valid?
  end
end
