require 'test_helper'

class ApprovedJobsControllerTest < ActionDispatch::IntegrationTest
setup do
  ApprovedJobsController.any_instance.stubs(:current_user).returns(create_test_user)
  ApprovedJobsController.any_instance.stubs(:authorize).returns(true)
end

  test 'approved jobs index' do

    2.times do
    create(:approved_job)
    end
    get "/approved_jobs"
    assert_response :ok
    assert_equal 2, json_res['data'].count
  end

  test 'approved jobs create' do
    post "/approved_jobs" ,params:{approved_job_name:"haozhigang",
                                  report_salary_count:"1111",
                                  report_salary_unit:"MOP"}
    assert_response :ok
  end
end
