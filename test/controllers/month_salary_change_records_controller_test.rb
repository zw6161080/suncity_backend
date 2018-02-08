require 'test_helper'

class MonthSalaryChangeRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile = create_profile
    user = profile.user
    salary_record_1 = create(:salary_record, user_id: user.id)
    salary_record_2 = create(:salary_record, user_id: user.id)
    month_salary_change_record = create(:month_salary_change_record,
                                        original_salary_record_id: salary_record_1.id,
                                        updated_salary_record_id: salary_record_2)
  end

  def test_columns
    get columns_month_salary_change_records_url
    assert_response :success
  end

  def test_options
    get options_month_salary_change_records_url
    assert_response :success
  end

  def test_index
    get month_salary_change_records_url, as: :json
    assert_response :success
  end

end
