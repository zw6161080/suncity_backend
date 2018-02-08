require "test_helper"

class PaidSickLeaveReportItemTest < ActiveSupport::TestCase
  def paid_sick_leave_report_item
    @paid_sick_leave_report_item ||= PaidSickLeaveReportItem.new
  end

  def test_valid
    assert paid_sick_leave_report_item.valid?
  end
end
