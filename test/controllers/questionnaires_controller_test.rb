require 'test_helper'

class QuestionnairesControllerTest < ActionDispatch::IntegrationTest
  setup do

    QuestionnairesController.any_instance.stubs(:current_user).returns(create_test_user)
    QuestionnairesController.any_instance.stubs(:authorize).returns(true)

  end

  test "should get index" do
    create(:user, id: 1)
    create(:questionnaire_template)
    create(:questionnaire)

    params_1 ={
      region: 'macau'
    }

    get '/questionnaires', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "RUD" do
    profile = create_profile
    user = profile.user
    location = create(:location, chinese_name: '新葡京')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '高級經理')
    location.departments << department
    department.positions << position
    user.location = location
    user.department = department
    user.position = position
    qt = create(:questionnaire_template)
    q = create(:questionnaire, user_id: user['id'])
    q.questionnaire_template_id = qt['id']
    q.save

    update_params = {
      region: 'macau',
      questionnaire_template_id: qt['id'],
      user_id: user['id'],
      is_filled_in: true,
      release_date: '2017/06/20',
      release_user_id: user['id'],
      submit_date: '2017/06/23',
      comment: 'test comment',

      fill_in_the_blank_questions: [
        {
          order_no: 1,
          question: 'text question 1',
          is_required: true,
          answer: 'answer 1',
        },
      ],

      choice_questions: [
        {
          order_no: 2,
          question: 'choice question 2',
          is_multiple: true,
          is_required: false,
          answer: [0, 1],
          options: [
            {
              option_no: 1,
              description: 'option 1',
              has_supplement: true,
              supplement: 'supplement 1',
            },
            {
              option_no: 2,
              description: 'option 2',
              has_supplement: true,
              supplement: 'supplement 2',
            },
            {
              option_no: 3,
              description: 'option 3',
              has_supplement: false,
              supplement: '',
            },
          ],
        },
        {
          order_no: 5,
          question: 'choice question 5',
          is_multiple: false,
          is_required: true,
          answer: [2],
          options: [
            {
              option_no: 1,
              description: 'option 1',
              supplement: 'supplement 1',
              attend_attachment: {
                file_name: '1.jpg',
                attachment_id: 1
              },
            },
            {
              option_no: 2,
              description: 'option 2',
              supplement: 'supplement 2',
              attend_attachment: {
                file_name: '2.jpg',
                attachment_id: 2
              },
            },
          ],
        },
      ],

      matrix_single_choice_questions: [
        {
          order_no: 3,
          title: 'matrix question 3',
          max_score: 10,
          matrix_single_choice_items: [
            {
              item_no: 1,
              question: 'matrix question 1',
              score: 5,
              is_required: false,
            },
            {
              item_no: 2,
              question: 'matrix question 2',
              score: 2,
              is_required: true,
            },
            {
              item_no: 3,
              question: 'matrix question 3',
              score: 9,
              is_required: true,
            },
          ],
        },
      ],
    }

    get "/questionnaires/#{q.id}", as: :json
    assert_response :ok


    assert_equal 0, json_res['data']['fill_in_the_blank_questions'].count
    assert_equal 0, json_res['data']['choice_questions'].count
    assert_equal 0, json_res['data']['matrix_single_choice_questions'].count

    put "/questionnaires/#{q.id}", params: update_params, as: :json
    assert_response :ok

    update_q = Questionnaire.first



    assert_equal 1, update_q.fill_in_the_blank_questions.count
    assert_equal 2, update_q.choice_questions.count
    assert_equal 1, update_q.matrix_single_choice_questions.count

    get "/questionnaires/#{update_q.id}", as: :json
    assert_response :ok

    get options_questionnaires_url
    assert_response :success
    assert_equal json_res['data']['filled_questionnaire_templates'].ids, [qt['id']]
    assert_equal json_res['data']['filled_questionnaire_departments'].ids, [department['id']]
    assert_equal json_res['data']['filled_questionnaire_positions'].ids, [position['id']]
    assert_equal json_res['data']['status_options'][0]['key'], true
    assert_equal json_res['data']['status_options'][0]['chinese_name'], '已填寫'
    assert_equal json_res['data']['status_options'][1]['key'], false
    assert_equal json_res['data']['status_options'][1]['chinese_name'], '未填寫'

    assert_difference(['Questionnaire.count'], -1) do
      q = Questionnaire.first
      delete "/questionnaires/#{q.id}"
    end

  end
end
