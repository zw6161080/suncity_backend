require "test_helper"

class RosterListTest < ActiveSupport::TestCase
  def roster_list
    @roster_list ||= RosterList.new
  end

  def test_valid
    assert roster_list.valid?
  end
end
