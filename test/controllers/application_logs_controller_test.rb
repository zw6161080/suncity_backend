require 'test_helper'

class ApplicationLogsControllerTest < ActionDispatch::IntegrationTest

  test "get list" do
    applicant_position = create(:applicant_position)
    get "/applicant_positions/#{applicant_position.id}/application_logs"

    assert_response :ok
  end

  test 'get types' do
    get "/application_logs/types"
    
    assert_equal json_res['data'].length, ApplicationLog.new.titles.length
  end

end
