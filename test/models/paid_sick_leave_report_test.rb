require "test_helper"

class PaidSickLeaveReportTest < ActiveSupport::TestCase
  def paid_sick_leave_report
    @paid_sick_leave_report ||= PaidSickLeaveReport.new
  end

  def test_valid
    assert paid_sick_leave_report.valid?
  end
end
