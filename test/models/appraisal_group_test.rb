require "test_helper"

class AppraisalGroupTest < ActiveSupport::TestCase
  def appraisal_group
    @appraisal_group ||= AppraisalGroup.new
  end

  def test_valid
    assert appraisal_group.valid?
  end
end
