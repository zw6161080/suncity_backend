# coding: utf-8
require 'test_helper'

class QuestionnaireTemplatesControllerTest < ActionDispatch::IntegrationTest

  setup do
    test_user = create_test_user
    QuestionnaireTemplatesController.any_instance.stubs(:current_user).returns(test_user)
    QuestionnaireTemplatesController.any_instance.stubs(:authorize).returns(true)

  end

  test "should get index" do
    create(:user, id: 1)
    create(:questionnaire_template)

    params_1 ={
      region: 'macau'
    }

    get '/questionnaire_templates', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "CRUD" do
    profile = create_profile
    user = profile.user

    params = {
      region: 'macau',
      chinese_name: '測試 1',
      english_name: 'test 1',
      simple_chinese_name: '测试 1',
      template_type: 'other',
      template_introduction: 'template_introduction',
      creator_id: user.id,
      comment: 'test comment',

      fill_in_the_blank_questions: [
        {
          order_no: 1,
          question: 'text question 1',
          is_required: true,
        },
        {
          order_no: 3,
          question: 'text question 3',
          is_required: false,
        },
      ],

      choice_questions: [
        {
          order_no: 2,
          question: 'choice question 2',
          is_multiple: true,
          is_required: false,
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

    update_params = {
      region: 'macau',
      chinese_name: 'update 測試 1',
      english_name: 'update test 1',
      simple_chinese_name: 'update 测试 1',
      template_type: 'other',
      template_introduction: 'update template_introduction',
      creator_id: user.id,
      comment: 'update test comment',

      fill_in_the_blank_questions: [
        {
          order_no: 1,
          question: 'text question 1',
          is_required: true,
        },
      ],

      choice_questions: [
        {
          order_no: 2,
          question: 'choice question 2',
          is_multiple: true,
          is_required: false,
          options: [
            {
              option_no: 1,
              description: 'option 1',
              supplement: 'supplement 1',
            },
            {
              option_no: 2,
              description: 'option 2',
              supplement: 'supplement 2',
            },
            {
              option_no: 3,
              description: 'option 3',
              supplement: 'supplement 3',
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

    assert_difference(['QuestionnaireTemplate.count'], 1) do
      post '/questionnaire_templates', params: params, as: :json
      assert_response :ok
    end

    qt = QuestionnaireTemplate.first
    get "/questionnaire_templates/#{qt.id}", as: :json
    assert_response :ok



    assert_equal 2, json_res['data']['fill_in_the_blank_questions'].count
    assert_equal 2, json_res['data']['choice_questions'].count
    assert_equal 3, json_res['data']['choice_questions'].first['options'].count
    assert_not_nil json_res['data']['choice_questions'][1]['options'].first['attend_attachments']
    assert_equal 1, json_res['data']['matrix_single_choice_questions'].count
    assert_equal 3, json_res['data']['matrix_single_choice_questions'].first['matrix_single_choice_items'].count

    put "/questionnaire_templates/#{qt.id}", params: update_params, as: :json
    assert_response :ok

    update_qt = QuestionnaireTemplate.first

    assert_equal 1, update_qt.fill_in_the_blank_questions.count
    assert_equal 1, update_qt.choice_questions.count
    assert_equal 1, update_qt.matrix_single_choice_questions.count

    get options_questionnaire_templates_url
    assert_response :success
    assert_equal json_res['data']['questionnaire_types'][0]['key'], 'entry_questionnaire'
    assert_equal json_res['data']['questionnaire_types'][0]['chinese_name'], '入職面談調查問卷'
    assert_equal json_res['data']['questionnaire_types'][1]['key'], 'leave_questionnaire'
    assert_equal json_res['data']['questionnaire_types'][1]['chinese_name'], '離職面談調查問卷'
    assert_equal json_res['data']['questionnaire_types'][2]['key'], '360_assessment'
    assert_equal json_res['data']['questionnaire_types'][2]['chinese_name'], '360 評核問卷'
    assert_equal json_res['data']['questionnaire_types'][3]['key'], 'train_exam'
    assert_equal json_res['data']['questionnaire_types'][3]['chinese_name'], '培訓考試'
    assert_equal json_res['data']['questionnaire_types'][4]['key'], 'student_evaluation'
    assert_equal json_res['data']['questionnaire_types'][4]['chinese_name'], '培訓學員評價'
    assert_equal json_res['data']['questionnaire_types'][5]['key'], 'train_supervisor_assessment'
    assert_equal json_res['data']['questionnaire_types'][5]['chinese_name'], '培训上司考核'
    assert_equal json_res['data']['questionnaire_types'][6]['key'], 'client_feedback'
    assert_equal json_res['data']['questionnaire_types'][6]['chinese_name'], '客戶意見問卷'
    assert_equal json_res['data']['questionnaire_types'][7]['key'], 'other'
    assert_equal json_res['data']['questionnaire_types'][7]['chinese_name'], '其他'
    assert_equal json_res['data']['questionnaire_templates'][0]['d'], qt.id

    assert_difference(['QuestionnaireTemplate.count'], -1) do
      qt = QuestionnaireTemplate.first
      delete "/questionnaire_templates/#{qt.id}"
    end

  end

  test "release questionnaire(user_ids)" do
    profile = create_profile
    user = profile.user

    qt = create(:questionnaire_template)

    params = {
      questionnaire_template_id: qt['id'],
      user_ids: [user.id],
      location_id: nil,
      department_id: nil,
      position_id: nil,
      template: {
        region: 'macau',
        questionnaire_template_id: qt['id'],
        is_filled_in: false,
        release_date: '2017/06/01',
        release_user_id: user.id,
        submit_date: '',
        comment: 'comment'
      }
    }

    assert_difference(['Questionnaire.count'], 1) do
      post "/questionnaire_templates/#{qt['id']}/release", params: params, as: :json
      q = Questionnaire.first
      assert_equal qt['id'], q['questionnaire_template_id']
    end

    get instances_questionnaire_template_url(qt['id'])
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    assert_equal json_res['data'][0]['questionnaire_template_id'], qt['id']
    assert_equal json_res['data'][0]['user_id'], user.id
    assert_equal json_res['data'][0]['is_filled_in'], false
    assert_equal json_res['data'][0]['release_date'], '2017/06/01'
    assert_equal json_res['data'][0]['release_user_id'], user.id

  end

  test "release questionnaire(location, department, position)" do
    profile = create_profile
    user = profile.user

    location = create(:location, id: 90,chinese_name: '银河')
    department = create(:department, id: 9,chinese_name: '行政及人力資源部')
    position = create(:position, id: 39, chinese_name: '網絡及系統副總監')

    user.location_id = location['id']
    user.department_id = department['id']
    user.position_id = position['id']
    user.save

    qt = create(:questionnaire_template)

    params = {
      questionnaire_template_id: qt['id'],
      user_ids: nil,
      location_id: location['id'],
      department_id: department['id'],
      position_id: position['id'],
      template: {
        region: 'macau',
        questionnaire_template_id: qt['id'],
        is_filled_in: false,
        release_date: '2017/06/01',
        release_user_id: user.id,
        submit_date: '',
        comment: 'comment'
      }
    }

    assert_difference(['Questionnaire.count'], 1) do
      post "/questionnaire_templates/#{qt['id']}/release", params: params, as: :json
      q = Questionnaire.first
      assert_equal qt['id'], q['questionnaire_template_id']
    end

    get instances_questionnaire_template_url(qt['id'])
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    assert_equal json_res['data'][0]['questionnaire_template_id'], qt['id']
    assert_equal json_res['data'][0]['user_id'], user.id
    assert_equal json_res['data'][0]['is_filled_in'], false
    assert_equal json_res['data'][0]['release_date'], '2017/06/01'
    assert_equal json_res['data'][0]['release_user_id'], user.id
    assert_equal json_res['data'][0]['department']['id'], department.id
    assert_equal json_res['data'][0]['position']['id'], position.id
  end
end
