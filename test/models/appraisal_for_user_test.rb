require "test_helper"

class AppraisalForUserTest < ActiveSupport::TestCase
  def appraisal_for_user
    @appraisal_for_user ||= AppraisalForUser.new
  end

  def test_valid
    assert appraisal_for_user.valid?
  end
end
