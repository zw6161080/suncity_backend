require "test_helper"

class SurplusSnapshotTest < ActiveSupport::TestCase
  def surplus_snapshot
    @surplus_snapshot ||= SurplusSnapshot.new
  end

  def test_valid
    assert surplus_snapshot.valid?
  end
end
