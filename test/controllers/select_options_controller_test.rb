require 'test_helper'

class SelectOptionsControllerTest < ActionDispatch::IntegrationTest
  test "the truth" do
    params = {
      key: 'get_info_from'
    }

    get '/select_options', params: params
    assert_response :ok
    assert_equal Select.get_options(:get_info_from).length, json_res['data'].count
  end
end
