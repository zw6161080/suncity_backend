require "test_helper"

class RevisionHistoryTest < ActiveSupport::TestCase
  def revision_history
    @revision_history ||= RevisionHistory.new
  end

  def test_valid
    assert revision_history.valid?
  end
end
