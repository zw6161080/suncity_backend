require "test_helper"

class AttendMonthApprovalTest < ActiveSupport::TestCase
  def attend_month_approval
    @attend_month_approval ||= AttendMonthApproval.new
  end

  def test_valid
    assert attend_month_approval.valid?
  end
end
