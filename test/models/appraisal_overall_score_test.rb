require "test_helper"

class AppraisalOverallScoreTest < ActiveSupport::TestCase
  def appraisal_overall_score
    @appraisal_overall_score ||= AppraisalOverallScore.new
  end

  def test_valid
    assert appraisal_overall_score.valid?
  end
end
