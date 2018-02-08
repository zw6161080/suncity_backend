require 'test_helper'

class InterviewersControllerTest < ActionDispatch::IntegrationTest
  setup do
    user = create(:user)
    InterviewersController.any_instance.stubs(:request_jwt_user_id).returns(user.id)

    applicant_profile = create_applicant_profile
    applicant_position = applicant_profile.applicant_positions.first
    interview = create(:interview, applicant_position_id: applicant_position.id)
    create(:interviewer, user_id: user.id, interview_id: interview.id, status: 4)
    create(:interviewer, user_id: user.id, interview_id: interview.id, status: 5)
  end

  test "get index and get mine" do
    get '/interviewers'
    assert_response :ok
    data = json_res['data']
    assert_equal json_res['data'].length, 2

    get '/interviewers/mine'
    assert_response :ok
    assert_equal json_res['data'], data
  end

  test "get waiting_for_interview" do
    get '/interviewers/waiting_for_interview'
    
    the_applicant_profile = json_res['data'].first.fetch('applicant_profile')
    assert_equal 2, json_res['data'].count
    assert_equal ApplicantProfile.last.id, the_applicant_profile['id']
    assert_equal "interview_needed", json_res['data'].first.fetch('status')
  end

  test "get all interviewers statuses" do
    get '/interviewers/statuses'

    statuses = {
      # "choose_needed" => 1,
      # "choose_agreed" => 2,
      # "choose_refused" => 3,
      "interview_needed" => 4,
      "interview_agreed" => 5,
      "interview_refused" => 6,
      "interview_completed" => 7,
      "interview_cancelled" => 8
    }

    assert_equal json_res['data'], statuses
  end

  test "patch update_status" do
    interviewer = Interviewer.last
    params = {
      status: 'interview_agreed',
      comment: 'test_comment_content'
    }

    current_user = create(:user)
    InterviewersController.any_instance.stubs(:current_user).returns(current_user)
    message_test_mock

    assert_difference(['ApplicationLog.count'], 1) do
      patch "/interviewers/#{interviewer.id}/update_status", params: params

      interviewer.reload
      assert_equal interviewer.status, "interview_agreed"
      assert_equal interviewer.comment, "test_comment_content"

      assert_response :ok
    end

    params = { status: 'interview_refused' }
    patch "/interviewers/#{interviewer.id}/update_status", params: params
    interviewer.reload
    assert_equal interviewer.status, "interview_refused"
    assert_equal interviewer.interview.interviewers.pluck(:status).uniq, ["interview_refused"]
    assert_equal interviewer.interview.result, "refused"

    assert_response :ok

    params = { status: 'interview_agreed' }
    patch "/interviewers/#{interviewer.id}/update_status", params: params
    interviewer.reload
    assert_equal interviewer.interview.result, "refused"
    assert_response :ok

    interviewer = interviewer.interview.interviewers.first
    params = { status: 'interview_agreed' }
    patch "/interviewers/#{interviewer.id}/update_status", params: params
    interviewer.reload
    assert_equal interviewer.interview.result, "refused"

    assert_response :ok
  end


end
