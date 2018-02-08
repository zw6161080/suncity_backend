require "test_helper"

class AnnualAwardReportItemTest < ActiveSupport::TestCase
  def annual_award_report_item
    @annual_award_report_item ||= AnnualAwardReportItem.new
  end

  def test_valid
    assert annual_award_report_item.valid?
  end
end
