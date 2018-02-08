require "test_helper"

class AnnualAttendReportTest < ActiveSupport::TestCase
  def annual_attend_report
    @annual_attend_report ||= AnnualAttendReport.new
  end

  def test_valid
    assert annual_attend_report.valid?
  end
end
