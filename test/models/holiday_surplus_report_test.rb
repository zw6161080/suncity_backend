require "test_helper"

class HolidaySurplusReportTest < ActiveSupport::TestCase
  def holiday_surplus_report
    @holiday_surplus_report ||= HolidaySurplusReport.new
  end

  def test_valid
    assert holiday_surplus_report.valid?
  end
end
