require "test_helper"

class LocationStatusTest < ActiveSupport::TestCase
  def location_status
    @location_status ||= LocationStatus.new
  end

  def test_valid
    assert location_status.valid?
  end
end
