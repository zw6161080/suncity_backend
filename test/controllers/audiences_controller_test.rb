require 'test_helper'

class AudiencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    position = create(:position_with_full_relations)
    applicant_profile = create_applicant_profile

    @applicant_position = create(:applicant_position)
    @applicant_position.position = position
    @applicant_position.department = position.departments.first
    @applicant_position.applicant_profile = applicant_profile
    @applicant_position.save
  end

  test "post create one audience and get all audiences list and get mine" do
    current_user = create(:user)
    user = create(:user)

    params = {
      comment: Faker::Lorem.sentence,
      user_email: user.email,
      status: "agreed",
      time: 'test time content'
    }

    AudiencesController.any_instance.stubs(:current_user).returns(current_user)
    
    message_test_mock
    assert_difference(['Audience.count', 'ApplicationLog.count'], 1) do
      post "/applicant_positions/#{@applicant_position.id}/audiences", params: params
      the_audience = @applicant_position.audiences.last.reload
      assert_equal the_audience.applicant_position, @applicant_position
      assert_equal the_audience.comment, params[:comment]
      assert_equal the_audience.creator, current_user
      assert_equal the_audience.user, user
      assert_response :ok
    end

    user = create(:user)
    new_audience = create(:audience, user_id: user.id, creator_id: current_user.id, applicant_position_id: @applicant_position.id)
    AudiencesController.any_instance.stubs(:current_user).returns(user)

    get "/audiences/mine"
    assert_response :ok
    assert_equal json_res['data'].length, 1
    assert_equal json_res['data'].first.fetch('user_id'), user.id
    assert_equal json_res['data'].first.fetch('creator_id'), current_user.id
    assert json_res['data'].first.keys.include? 'applicant_profile'
    assert json_res['data'].first.keys.include? 'creator'
    assert json_res['data'].first.keys.include? 'first_interview'
    assert json_res['data'].first.keys.include? 'applicant_position'
  end

  test "patch update one audience" do
    audience = Audience.new
    @applicant_position.audiences << audience

    params = {
      comment: Faker::Lorem.sentence
    }

    current_user = create(:user)
    AudiencesController.any_instance.stubs(:current_user).returns(current_user)

    assert_difference('Audience.count', 0) do
    assert_difference('ApplicationLog.count', 1) do
      patch "/applicant_positions/#{@applicant_position.id}/audiences/#{audience.id}", params: params, as: :json
      audience.reload

      assert_equal audience.comment, params[:comment]
      assert_response :ok
    end
    end
  end

  test "get audience statuses" do
    get '/audiences/statuses'

    assert_equal json_res['data'].length, 3
  end

end
