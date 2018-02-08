require "test_helper"

class StudentEvaluationsControllerttTest < ActionDispatch::IntegrationTest

  setup do
    StudentEvaluationsController.any_instance.stubs(:authorize).returns(true)
  end

  test "should get index" do
    create(:user, id: 1)
    create(:student_evaluation)

    params_1 ={
      region: 'macau'
    }

    get '/student_evaluations', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    create(:user, id: 1)
    se = create(:student_evaluation)

    params_1 ={
      region: 'macau'
    }

    get "/student_evaluations/#{se.id}", params: params_1
    assert_response :success

    assert_equal 100, json_res['data']['satisfaction'].to_i
  end

  test "should update" do
    create(:user, id: 1)
    questionnaire = create(:questionnaire)
    se = create(:student_evaluation)
    se.create_attend_questionnaire(questionnaire_id: questionnaire.id)
    params_1 = {
      region: 'macau',
      satisfaction: 1000
    }

    put "/student_evaluations/#{se.id}", params: params_1, as: :json
    assert_response :success

    new_se = StudentEvaluation.find(se.id)
    assert_equal 1000, new_se['satisfaction']
  end
end
