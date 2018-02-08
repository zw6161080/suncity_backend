require "test_helper"

class RosterModelTest < ActiveSupport::TestCase
  def roster_model
    @roster_model ||= RosterModel.new
  end

  def test_valid
    assert roster_model.valid?
  end
end
