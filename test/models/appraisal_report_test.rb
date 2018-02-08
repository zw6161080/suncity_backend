require "test_helper"

class AppraisalReportTest < ActiveSupport::TestCase
  def appraisal_report
    @appraisal_report ||= AppraisalReport.new
  end

  def test_valid
    assert appraisal_report.valid?
  end
end
