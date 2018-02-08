require "test_helper"

class AppraisalTest < ActiveSupport::TestCase
  def appraisal
    @appraisal ||= Appraisal.new
  end

  def test_valid
    assert appraisal.valid?
  end
end
