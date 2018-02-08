require 'test_helper'

class AssessmentQuestionnaireItemsControllerTest < ActionDispatch::IntegrationTest
  test "get questionnaire_template" do
    user = create(:user)
    get '/job_transfers/get_questionnaire_template', params: { user_id: user.id }

    assert_response :ok
    assert_equal 20, json_res['data'].count
  end

  test "get questionnaire_template: grade < 5" do
    user = create(:user)
    user.grade = 1
    user.save
    get '/job_transfers/get_questionnaire_template', params: { user_id: user.id }

    assert_response :ok
    assert_equal 20, json_res['data'].count

    # 9 - 16 assessment_questionnaire_items for grade under 5
    assert_equal 8, json_res['data'].select { |item| item['order_no'] >= 9 && item['order_no'] <= 16 }.count
  end

  test "get questionnaire_template: grade == 5" do
    user = create(:user)
    user.grade = 5
    user.save
    get '/job_transfers/get_questionnaire_template', params: { user_id: user.id }

    assert_response :ok
    assert_equal 20, json_res['data'].count

    # 1 - 8 assessment_questionnaire_items for grade 5
    assert_equal 8, json_res['data'].select { |item| item['order_no'] >= 1 && item['order_no'] <= 8 }.count
  end
end
