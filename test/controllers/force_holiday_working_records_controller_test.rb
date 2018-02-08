require 'test_helper'

class ForceHolidayWorkingRecordsControllerTest < ActionDispatch::IntegrationTest

  def test_index
    get force_holiday_working_records_url
    assert_response :success
  end

end
