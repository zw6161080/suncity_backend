require "test_helper"

class RosterObjectTest < ActiveSupport::TestCase
  def roster_object
    @roster_object ||= RosterObject.new
  end

  def test_valid
    assert roster_object.valid?
  end
end
