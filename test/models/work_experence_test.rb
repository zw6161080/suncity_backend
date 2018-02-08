require "test_helper"

class WorkExperenceTest < ActiveSupport::TestCase
  def work_experence
    @work_experence ||= WorkExperence.new
  end

  def test_valid
    assert work_experence.valid?
  end
end
