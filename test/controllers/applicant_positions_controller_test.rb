require 'test_helper'

class ApplicantPositionsControllerTest < ActionDispatch::IntegrationTest
  #  id                   :integer          not null, primary key
  #  department_id        :integer
  #  position_id          :integer
  #  applicant_profile_id :integer
  #  created_at           :datetime         not null
  #  updated_at           :datetime         not null
  #  order                :string
  #  status               :integer          default("not_started")
  #  comment              :text
  #
  setup do
    @applicant_position = create(:applicant_position,
                                 status: "choose_needed",
    )
    create(:applicant_position,
           status: "choose_failed",
    )
    create(:applicant_position,
           status: "choose_failed",
    )
    create(:applicant_position,
           status: "choose_failed",
    )
    create(:applicant_position,
           status: "contract_needed",
    )
    create(:applicant_position,
           status: "entry_not_finished",
    )
  end

  test "获取申请职位详情" do
    profile = create_applicant_profile
    get "/applicant_positions/#{profile.first_applicant_position_id}"
    assert_response :ok
  end

  test "patch update status" do
    profile = create_applicant_profile
    params = { status: 'first_interview_succeed' }

    current_user = create(:user)
    ApplicantPositionsController.any_instance.stubs(:current_user).returns(current_user)
    
    assert_difference(['ApplicationLog.count'], 1) do
      patch "/applicant_positions/#{profile.first_applicant_position_id}/update_status", params: params
      assert_equal profile.applicant_positions.first.reload.status, 'first_interview_succeed'
      assert_response :ok
    end

  end

  test 'get statuses' do
    get '/applicant_positions/statuses'

    assert_equal json_res['data'].length, ApplicantPosition.statuses.length
    assert_response :ok
  end

  test 'get summary' do
    get '/applicant_positions/summary'
    assert_response :ok
    assert_equal json_res['data'].length, 5
    assert_equal json_res['data']['applicant_sum'], 6
    assert_equal json_res['data']['choose_needed'], 1
    assert_equal json_res['data']['contract_needed'], 1
  end

  test 'patch create empoid' do
    applicant_profile = create_applicant_profile
    applicant_position = applicant_profile.applicant_positions.first
    applicant_position.update_column(:status, :accepted)
    assert_difference(['User.count', 'Profile.count'], 0) do
      patch "/applicant_positions/#{applicant_position.id}/create_empoid"
      assert_response :ok
    end
  end
end
