require "test_helper"

class SupervisorAssessmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:user, id: 1)
    create(:supervisor_assessment)

    params_1 ={
      region: 'macau'
    }

    get '/supervisor_assessments', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    create(:user, id: 1)
    sa = create(:supervisor_assessment)

    params_1 ={
      region: 'macau'
    }

    get "/supervisor_assessments/#{sa.id}", params: params_1
    assert_response :success

    assert_equal 100, json_res['data']['score']
  end

  test "should update" do
    create(:user, id: 1)
    questionnaire = create(:questionnaire)
    sa = create(:supervisor_assessment)
    sa.create_attend_questionnaire(questionnaire_id: questionnaire.id)
    params_1 = {
      region: 'macau',
      score: 1000
    }

    put "/supervisor_assessments/#{sa.id}", params: params_1, as: :json
    assert_response :success

    new_sa = SupervisorAssessment.find(sa.id)
    assert_equal 1000, new_sa['score']
  end
end
