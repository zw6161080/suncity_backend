require "test_helper"

class EntryAndLeaveStatisticsControllerTest < ActionDispatch::IntegrationTest
  def test_columns
    get columns_entry_and_leave_statistics_url
    assert_response :success
  end

  def test_options
    get options_entry_and_leave_statistics_url
    assert_response :success
  end

  def test_index
    get entry_and_leave_statistics_url
    assert_response :success
  end
end
