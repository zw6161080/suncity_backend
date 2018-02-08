require 'test_helper'

class DimissionAppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    DimissionAppointmentsController.any_instance.stubs(:current_user).returns(create_test_user)
    DimissionAppointmentsController.any_instance.stubs(:authorize).returns(true)

  end


  test "should get index" do
    create(:user, id: 1)
    create(:dimission_appointment)

    params_1 ={
      region: 'macau'
    }

    get '/dimission_appointments', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test 'should export_xlsx' do
    DimissionAppointmentsController.any_instance.stubs(:current_user).returns(User.first)
    params_2 ={
        region: 'macau'
    }
    get '/dimission_appointments/export_xlsx', params: params_2
    assert_response :success
  end

  def test_cud
    QuestionnairesController.any_instance.stubs(:authorize).returns(true)
    QuestionnaireTemplatesController.any_instance.stubs(:authorize).returns(true)
    profile = create_profile
    user = profile.user
    location = create(:location, id: 1, chinese_name: '新葡京')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '高級經理')
    location.departments << department
    department.positions << position
    user.location = location
    user.department = department
    user.position = position
    qt = create(:questionnaire_template, template_type: 'leave_questionnaire')
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

    put "/questionnaires/#{q.id}", params: update_params, as: :json
    assert_response :ok

    update_q = Questionnaire.first

    get "/questionnaires/#{update_q.id}", as: :json
    assert_response :ok

    dimission_appointment_params = {
        questionnaire_template_id: qt.id,
        region: 'macau',
        user_id: user.id,
        status: 'have_not_started',
        questionnaire_id: update_q.id,
        appointment_date: '2018/01/01',
        appointment_time: '12:00',
        appointment_location: location.id,
        appointment_description: 'hh',
        inputter_id: user.id,
        input_date: '2018/01/01',
        comment: 'hh',
    }
    post dimission_appointments_url, as: :json, params: dimission_appointment_params
    assert_response :ok
    assert_equal json_res['data'], DimissionAppointment.last.id
    assert_equal json_res['state'], 'success'

    ea = DimissionAppointment.last

    get dimission_appointment_url(ea.id)
    assert_response :ok
    assert_equal json_res['data']['id'], ea.id
    assert_equal json_res['data']['user_id'], user.id
    assert_equal json_res['data']['status'], 'have_not_started'
    assert_equal json_res['data']['questionnaire_template_id'], qt.id
    assert_equal json_res['data']['questionnaire_id'], q.id

    get options_dimission_appointments_url
    assert_response :ok
    assert_equal json_res['data']['status_types'][0]['key'], 'have_not_started'
    assert_equal json_res['data']['status_types'][0]['chinese_name'], '未啟動'
    assert_equal json_res['data']['status_types'][1]['key'], 'wait_for_filling_in_the_questionnaire'
    assert_equal json_res['data']['status_types'][1]['chinese_name'], '待填問卷'
    assert_equal json_res['data']['status_types'][2]['key'], 'wait_for_making_the_appointment'
    assert_equal json_res['data']['status_types'][2]['chinese_name'], '待面談'
    assert_equal json_res['data']['status_types'][3]['key'], 'finished'
    assert_equal json_res['data']['status_types'][3]['chinese_name'], '已完成'
    assert_equal json_res['data']['questionnaire_templates'][0]['id'], qt.id

    update_params = {
        questionnaire_template_id: qt.id,
        region: 'macau',
        user_id: user.id,
        status: 'have_not_started',
        questionnaire_id: update_q.id,
        appointment_date: '2018/01/01',
        appointment_time: '13:00',
        appointment_location: location.id,
        appointment_description: 'hh',
        inputter_id: user.id,
        input_date: '2018/01/01',
        comment: 'hh',
    }
    patch dimission_appointment_url(ea.id), as: :json, params: update_params
    assert_response :ok
    assert_equal DimissionAppointment.find(json_res['data']).appointment_time, '13:00'

    get send_content_dimission_appointment_url(ea.id)
    assert_response :ok
    assert_equal json_res['data']['sms'], '太陽城集團人力資源部短訊：感謝您這段日子對集團的努力付出和貢獻！茲 通知閣下進行離職面談。
                   請於[2018年1月1日 13時0分],
                    前來1面談，務必提前填寫 離職面談調查問卷 ，謝謝。
                    如有任何疑問，請於辦公時間內致電太陽城人力資源部： +853 8891 1332'
    assert_equal json_res['data']['email'], '感謝您這段日子對集團的努力付出和貢獻！請閣下務必提前填寫 離職面談調查問卷 ，并準時進行離職面談。
                     面談時間：[2018年1月1日 13時0分]
                     面談地點：1
                     如有任何疑問，請於辦公時間內致電太陽城人力資源部： +853 8891 1332'


    assert_difference(['DimissionAppointment.count'], -1) do
      delete dimission_appointment_url(ea.id)
      assert_response :ok
    end
  end
end
