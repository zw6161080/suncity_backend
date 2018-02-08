require "test_helper"

class PerformanceInterviewTest < ActiveSupport::TestCase
  def performance_interview
    @performance_interview ||= PerformanceInterview.new
  end

  def test_valid
    assert performance_interview.valid?
  end
end
