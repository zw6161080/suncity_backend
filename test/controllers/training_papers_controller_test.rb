require "test_helper"

class TrainingPapersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:user, id: 1)
    create(:training_paper)

    params_1 ={
      region: 'macau'
    }

    get '/training_papers', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    create(:user, id: 1)
    tp = create(:training_paper)
    tp.score = 1000
    tp.save

    params_1 ={
      region: 'macau'
    }

    get "/training_papers/#{tp.id}", params: params_1
    assert_response :success

    assert_equal 1000, json_res['data']['score']
  end

  test "should update" do
    create(:user, id: 1)
    tp = create(:training_paper)

    params_1 = {
      region: 'macau',
      score: 1000
    }

    put "/training_papers/#{tp.id}", params: params_1, as: :json
    assert_response :success

    new_tp = TrainingPaper.find(tp.id)
    assert_equal 1000, new_tp['score']
  end
end
