require 'test_helper'
require 'sidekiq/testing'

class SmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Sidekiq::Testing.fake!
  end
  
  test "patch templates" do
    params = {
      first_interview_time: "first-interview-time-string",
      second_interview_time: "second-interview-time-string",
      third_interview_time: "third-interview-time-string",
      contract_notice_time: "contract-notice-time-string",
      change_contract_time: "change-contract-time-string",
      applicant_no: 'R-11111',
      position_name: 'the-position-name',
      applicant_name: 'test-applicant-name'
    }
    patch '/sms/templates', params: params

    assert !response.body.match(/［/)
    assert !response.body.match(/］/)
    assert !response.body.match(/%{/)

    assert response.body.match(/R-11111/)
    assert response.body.match(/the-position-name/)
    assert response.body.match(/test-applicant-name/)
    assert response.body.match(/first-interview-time-string/)
    assert response.body.match(/second-interview-time-string/)
    assert response.body.match(/third-interview-time-string/)
    assert response.body.match(/contract-notice-time-string/)
    assert response.body.match(/change-contract-time-string/)

    assert_response :ok
  end

  test "patch delivery" do

    current_user = create(:user)
    SmsController.any_instance.stubs(:current_user).returns(current_user)
    SmsController.any_instance.stubs(:authorize).returns(true)
    
    @applicant_position = create(:applicant_position)
    interview = create(:interview)
    @applicant_position.interviews << interview

    params = {
      to: '+8613011111111',
      content: 'test content',
      the_object: 'interview',
      the_object_id: interview.id,
      content_changed: '1'
    }

    assert_difference(['Sms.count', 'Sidekiq::Queues["sms"].size', 'ApplicationLog.count'], 1) do
      patch '/sms/delivery', params: params, headers: { Token: current_user.token }
      assert_response :ok
      assert ApplicationLog.last.info.fetch('changes').fetch('content_changed')
    end

    assert_response :ok
  end

  test "post delivery sms" do
    current_user = create(:user)
    SmsController.any_instance.stubs(:current_user).returns(current_user)
    SmsController.any_instance.stubs(:authorize).returns(true)
    assert_difference(['Sms.count', 'Sidekiq::Queues["sms"].size'], 1) do
      post '/sms/delivery_sms', params: {to: '+8613011111111', content: '短信内容'}, headers: { Token: current_user.token }
      assert_response :success
    end
  end
end
