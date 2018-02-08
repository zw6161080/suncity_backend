require 'test_helper'
require 'sidekiq/testing'

class EmailControllerTest < ActionDispatch::IntegrationTest
  setup do
    Sidekiq::Testing.fake!

    current_user = create(:user)
    EmailController.any_instance.stubs(:current_user).returns(current_user)
    EmailController.any_instance.stubs(:authorize).returns(true)
  end

  test "get types" do
    get '/email/types'

    data = [
      "audience_choose_needed_to_interviewer",
      "audience_agreed_to_hr",
      "audience_refused_to_hr",
      "interview_to_interviewer"
    ]

    assert_equal data.sort, json_res['data'].sort
    assert_response :ok
  end

  test "patch delivery" do

    user = create(:user)
    applicant_profile = create_applicant_profile
    applicant_position = applicant_profile.applicant_positions.first
    interview = create(:interview, applicant_position_id: applicant_position.id)
    interviewer = create(:interviewer, user_id: user.id, interview_id: interview.id)

    # params = {
    #   email_type: "choose_needed_to_interviewer",
    #   applicant_position_id: applicant_position.id,
    #   interview_id: interview.id,
    #   interviewer_id: interviewer.id
    # }

    params = {
      to: "test@fake.com",
      subject: 'test subject',
      body: 'test body',
      the_object: 'applicant_position',
      the_object_id: applicant_position.id
    }

    current_user = create(:user)
    EmailController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference(['Sidekiq::Queues["email"].size', 'ApplicationLog.count'], 1) do
      patch '/email/delivery', params: params
      assert_response :ok
      assert EmailObject.last.body.match(/此郵件為系統自動發送，請勿回復郵件/)
    end


  end

  test "get templates" do
    user = create(:user)
    applicant_profile = create_applicant_profile
    applicant_position = applicant_profile.applicant_positions.first
    interview = create(:interview, applicant_position_id: applicant_position.id)
    audience = create(:audience, user_id: user.id, applicant_position_id: applicant_position.id)

    applicant_position.position.update_attributes({chinese_name: 'test-position-name'})

    get '/email/templates', params: { applicant_position_id: applicant_position.id, email_type: 'audience_choose_needed_to_interviewer'}
    assert json_res['data']['body'].match(/test-position-name/)
    assert json_res['data']['subject'].match(/面試邀請/)
    assert_response :ok

    get '/email/templates', params: { audience_id: audience.id, email_type: 'audience_agreed_to_hr'}
    assert json_res['data']['body'].match(/test-position-name/)
    assert json_res['data']['subject'].match(/面試回覆/)
    assert_response :ok

    get '/email/templates', params: { audience_id: audience.id, email_type: 'audience_refused_to_hr'}
    assert json_res['data']['body'].match(/test-position-name/)
    assert json_res['data']['subject'].match(/面試回覆/)
    assert_response :ok

    get '/email/templates', params: { interview_id: interview.id, email_type: 'interview_to_interviewer'}
    assert json_res['data']['body'].match(/test-position-name/)
    assert json_res['data']['subject'].match(/面試回覆/)
    assert_response :ok
  end

  test "post delivery email" do
    assert_difference(['Sidekiq::Queues["email"].size'], 1) do
      post '/email/delivery_email', params: {to: 'test@fake.com', subject: '邮件标题', body: '邮件内容'}
      assert_response :success
      assert_equal 'test@fake.com', EmailObject.last.to
      assert EmailObject.last.body.match(/邮件内容/)
    end
  end

end
