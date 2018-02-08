require "test_helper"

class AppraisalParticipatorTest < ActiveSupport::TestCase
  def appraisal_participator
    @appraisal_participator ||= AppraisalParticipator.new
  end

  def test_valid
    assert appraisal_participator.valid?
  end
end
