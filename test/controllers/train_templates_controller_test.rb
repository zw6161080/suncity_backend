require 'test_helper'

class TrainTemplatesControllerTest < ActionDispatch::IntegrationTest
  # let(:train_template) { train_templates :one }
  setup do
    TrainTemplatesController.any_instance.stubs(:authorize).returns(true)
    AttachmentsController.any_instance.stubs(:authorize).returns(true)
    TrainTemplatesController.any_instance.stubs(:current_user).returns(@current_user = create(:user))
    seaweed_webmock
  end

  test 'create train_template  and update_train_template' do
    qt = create(:questionnaire_template)
    template_update_params = {
        region: 'macau',
        chinese_name: 'update 測試 1',
        english_name: 'update test 1',
        simple_chinese_name: 'update 测试 1',
        template_type: 'other',
        template_introduction: 'update template_introduction',
        creator_id: @current_user.id,
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
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        is_required: true,
                    },
                ],
            },
        ],
    }
    put "/questionnaire_templates/#{qt.id}", params: template_update_params, as: :json
    assert_difference('TrainTemplate.count', 1) do
      post train_templates_url, params: {
          chinese_name: "string",
          english_name: "string",
          simple_chinese_name: "string",
          course_number: "string",
          teaching_form: "string",
          train_template_type_id: create(:train_template_type).id,
          training_credits: "string",
          online_or_offline_training: "online_training",
          limit_number: 0,
          course_total_time: "string",
          course_total_count: "string",
          trainer: "string",
          language_of_training: "string",
          place_of_training: "string",
          contact_person_of_training: "string",
          course_series: "string",
          course_certificate: "string",
          introduction_of_trainee: "string",
          introduction_of_course: "string",
          goal_of_learning: "string",
          content_of_course: "string",
          goal_of_course: "string",
          assessment_method: "by_attendance_rate",
          comprehensive_attendance_not_less_than: "string",
          test_scores_not_less_than: "string",
          exam_format: "online",
          exam_template_id: 1,
          comprehensive_attendance_and_test_scores_not_less_than: "string",
          test_scores_percentage: "string",
          notice: "string",
          comment: "string",
          online_materials: [
              {
                  name: "string",
                  file_name: "string",
                  instruction: "string",
                  attachment_id: create(:attachment).id
              },
              {
                  name: "string",
                  file_name: "string",
                  instruction: "string",
                  attachment_id: create(:attachment).id
              }
          ],
          attend_attachments: [
              {
                  attachment_id: create(:attachment).id,
                  file_name: "string",
                  comment: "string"
              }
          ]
      }
      assert_response :ok
      assert_equal TrainTemplate.first.chinese_name, 'string'
      assert_equal TrainTemplate.first.online_materials.first.name, 'string'
      assert_equal TrainTemplate.first.attend_attachments.first.creator_id, @current_user.id
    end
    patch train_template_url(TrainTemplate.first.id), params: {
        chinese_name: "string1",
        online_materials:
            [
                {
                    name: "string1",
                    file_name: "string2",
                    instruction: "string3",
                    attachment_id: @test_id =create(:attachment).id
                }
            ],
        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
                value: 1000,
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                is_multiple: true,
                is_required: false,
                right_answer:[1],
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
            }
        ]
    }
    assert_response :ok
    assert_equal @response.body, TrainTemplate.first.id.to_s
    assert_equal TrainTemplate.first.chinese_name, 'string1'
    assert_equal TrainTemplate.first.online_materials.count, 1
    assert_equal TrainTemplate.first.attend_attachments.count, 1


    get train_template_url(TrainTemplate.first.id)
    assert_response :ok
    assert_equal json_res['data']['id'], TrainTemplate.first.id
    assert json_res['data']['online_materials'][0].keys.include? 'name'

    get train_templates_url, as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['id'], TrainTemplate.first.id
    assert_equal json_res['data'][0]['train_template_type']['id'], TrainTemplateType.first.id

    get field_options_train_templates_url, as: :json
    assert_response :ok
    assert_equal json_res['data']['train_template_type'].first['id'], TrainTemplateType.first.id
    assert_equal json_res['data']['assessment_method'].first['key'], 'by_attendance_rate'

    get train_templates_url(exam_format: 'online'), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 1
    get train_templates_url(exam_format: 'offline'), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 0
    get train_templates_url(assessment_method: 'by_attendance_rate'), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 1
    get train_templates_url(assessment_method: 'by_test_scores'), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 0
    get train_templates_url(updated_at_begin: (Time.zone.now - 1.day).to_s,
                            updated_at_end: (Time.zone.now + 1.day).to_s), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 1
    get train_templates_url(updated_at_begin: (Time.zone.now + 1.day).to_s,
                            updated_at_end: (Time.zone.now + 2.day).to_s), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 0
    get train_templates_url(updated_at_begin: (Time.zone.now - 1.day).to_s
                            ), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 1

    get train_templates_url(creator_name: @current_user.chinese_name
        ), as: :json
    assert_response :ok
    assert_equal json_res['meta']['total_count'], 1

  end

  test 'should create train_template 创建模板测试方法为by_both' do
    qt = create(:questionnaire_template)
    template_update_params = {
        region: 'macau',
        chinese_name: 'update 測試 1',
        english_name: 'update test 1',
        simple_chinese_name: 'update 测试 1',
        template_type: 'other',
        template_introduction: 'update template_introduction',
        creator_id: @current_user.id,
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
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        is_required: true,
                    },
                ],
            },
        ],
    }
    put "/questionnaire_templates/#{qt.id}", params: template_update_params, as: :json

    assert_difference('TrainTemplate.count', 1) do
      post train_templates_url, params: {
          chinese_name: "string",
          english_name: "string",
          simple_chinese_name: "string",
          course_number: "string",
          teaching_form: "string",
          train_template_type_id: create(:train_template_type).id,
          training_credits: "string",
          online_or_offline_training: "online_training",
          limit_number: 0,
          course_total_time: "string",
          course_total_count: "string",
          trainer: "string",
          language_of_training: "string",
          place_of_training: "string",
          contact_person_of_training: "string",
          course_series: "string",
          course_certificate: "string",
          introduction_of_trainee: "string",
          introduction_of_course: "string",
          goal_of_learning: "string",
          content_of_course: "string",
          goal_of_course: "string",
          assessment_method: "by_both",
          exam_format: "online",
          exam_template_id: qt.id,
          comprehensive_attendance_and_test_scores_not_less_than: "string",
          test_scores_percentage: "string",
          notice: "string",
          comment: "string",
          online_materials: [
              {
                  name: "string",
                  file_name: "string",
                  instruction: "string",
                  attachment_id: create(:attachment).id
              },
              {
                  name: "string",
                  file_name: "string",
                  instruction: "string",
                  attachment_id: create(:attachment).id
              }
          ],
          attend_attachments: [
              {
                  attachment_id: create(:attachment).id,
                  file_name: "string",
                  comment: "string"
              }
          ]
      }
      assert_response :ok
      assert_equal TrainTemplate.first.chinese_name, 'string'
      assert_equal TrainTemplate.first.online_materials.first.name, 'string'
      assert_equal TrainTemplate.first.attend_attachments.first.creator_id, @current_user.id
      assert_equal TrainTemplate.first.assessment_method, 'by_both'
    end

  end

  test "post create one profile attachment and download file" do
    @train_template = create(:train_template)
    @online_material = create(:online_material)
    @attach = create(:attachment)
    @train_template.online_materials << @online_material
    attachment_params = {
        file: fixture_file_upload('files/test_send_to_seaweed.txt')
    }

    assert_difference('Attachment.count', 1) do
      post "/attachments", params: attachment_params

      assert_nil json_res['data'].fetch('seaweed_hash', nil)
      assert_equal json_res['data']['file_name'], 'test_send_to_seaweed.txt'

      assert_response :ok
    end

    params = {
        id: @train_template.online_materials.first.id
      }


      get "/attachments/#{@attach.id}/download", params: params

      assert_response :ok

    end

end



