require 'test_helper'

class InterviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    position = create(:position_with_full_relations)
    applicant_profile = create_applicant_profile

    @applicant_position = create(:applicant_position)
    @applicant_position.position = position
    @applicant_position.department = position.departments.first
    @applicant_position.applicant_profile = applicant_profile
    @applicant_position.save

    current_user = create(:user)
    InterviewsController.any_instance.stubs(:current_user).returns(current_user)
    InterviewsController.any_instance.stubs(:authorize).returns(true)
  end

  test "post create one interview and get all interviews list with interviewer users and get one interview interviewers" do
    users = []
    3.times do
      users << create(:user)
    end

    params = {
      time: Faker::Lorem.sentence,
      interviewer_emails: users.map{ |u| u.email },
      comment: Faker::Lorem.sentence,
    }

    current_user = create(:user)
    InterviewsController.any_instance.stubs(:current_user).returns(current_user)
    
    message_test_mock
    assert_difference(['Interview.count', 'ApplicationLog.count'], 1) do
      post "/applicant_positions/#{@applicant_position.id}/interviews", params: params, as: :json
      the_interview = @applicant_position.interviews.last.reload
      assert_equal the_interview.applicant_position, @applicant_position
      assert_equal the_interview.comment, params[:comment]
      assert_equal the_interview.interviewer_users, users
      assert_response :ok
    end

    get "/applicant_positions/#{@applicant_position.id}/interviews"
    assert_equal json_res['data'].first.fetch('interviewer_users').map{ |u| u['email'] }, users.map{ |u| u.email }
    assert_response :ok

    the_interview = @applicant_position.interviews.last.reload
    get "/applicant_positions/#{@applicant_position.id}/interviews/#{the_interview.id}/interviewers"
    assert_equal json_res['data'].map{ |u| u['email'] }, users.map{ |u| u.email }
    assert_response :ok

  end

  test "patch update one interview" do
    user = create(:user)

    interview = create(:interview)
    @applicant_position.interviews << interview
    interview.interviewers << create(:interviewer)

    params = {
      comment: Faker::Lorem.sentence,
      result: "cancelled",
      score: 7,
      evaluation: "evaluation test content.",
      need_again: 1,
      time: "2016年09月27日 下午02時30分",
      cancel_reason: "test_cancel_reason",
      interviewer_emails: [ user.email ]
    }

    current_user = create(:user)
    InterviewsController.any_instance.stubs(:current_user).returns(current_user)

    message_test_mock
    assert_difference('Interview.count', 0) do
    assert_difference(['ApplicationLog.count', 'Interviewer.count'], 1) do
      patch "/applicant_positions/#{@applicant_position.id}/interviews/#{interview.id}", params: params, as: :json
      interview.reload

      assert_equal interview.time, params[:time]
      assert_equal interview.comment, params[:comment]
      assert_equal interview.result, 'cancelled'
      assert_equal interview.score, 7
      assert_equal interview.evaluation, params[:evaluation]
      assert_equal interview.need_again, 1
      assert_equal interview.cancel_reason, "test_cancel_reason"
      assert_equal interview.interviewers.pluck(:status).uniq, ["interview_cancelled"]

      assert_response :ok
    end
    end

    assert_difference(['Interviewer.count'], 0) do
      patch "/applicant_positions/#{@applicant_position.id}/interviews/#{interview.id}", params: params, as: :json
      interview.reload

      assert_response :ok
    end

  end

  test "patch add interviewers and remove interviewers" do
    user = create(:user)

    interview = create(:interview)
    @applicant_position.interviews << interview

    params = {
      interviewer_emails: [ user.email ]
    }

    current_user = create(:user)
    InterviewsController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference(['Interviewer.count', 'ApplicationLog.count'], 1) do
      patch "/applicant_positions/#{@applicant_position.id}/interviews/#{interview.id}/add_interviewers", params: params, as: :json
    end
    assert_response :ok

    # current_user = create(:user)
    # InterviewsController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference('ApplicationLog.count', 1) do
    assert_difference('Interviewer.count', -1) do
      patch "/applicant_positions/#{@applicant_position.id}/interviews/#{interview.id}/remove_interviewers", params: params, as: :json
      assert_response :ok
    end
    end

  end

end
