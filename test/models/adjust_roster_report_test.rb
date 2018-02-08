require "test_helper"

class AdjustRosterReportTest < ActiveSupport::TestCase
  def adjust_roster_report
    @adjust_roster_report ||= AdjustRosterReport.new
  end

  def test_valid
    assert adjust_roster_report.valid?
  end
end
