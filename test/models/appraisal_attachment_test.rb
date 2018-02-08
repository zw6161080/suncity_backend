require "test_helper"

class AppraisalAttachmentTest < ActiveSupport::TestCase
  def appraisal_attachment
    @appraisal_attachment ||= AppraisalAttachment.new
  end

  def test_valid
    assert appraisal_attachment.valid?
  end
end
