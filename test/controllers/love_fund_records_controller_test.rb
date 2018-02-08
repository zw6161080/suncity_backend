require "test_helper"

class LoveFundRecordsControllerTest < ActionDispatch::IntegrationTest
  test 'get index by user' do
    test_user1  = create_test_user
    LoveFund.create_with_params(test_user1,  Time.zone.now, 'participated_in_the_future', test_user1.id)
    get index_by_user_love_fund_records_url(user_id: test_user1.id)
    assert_response :ok
    assert_equal json_res.count, 1

  end
end