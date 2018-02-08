require 'test_helper'

class AppraisalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    AppraisalAttachmentsController.any_instance.stubs(:authorize).returns(true)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:view_from_department, :appraisal, :macau)
    user = create_test_user
    user.add_role(@admin_role)
    AppraisalsController.any_instance.stubs(:current_user).returns(user)
    AppraisalsController.any_instance.stubs(:authorize).returns(true)
    QuestionnaireTemplatesController.any_instance.stubs(:authorize).returns(true)
    AppraisalBasicSettingsController.any_instance.stubs(:authorize).returns(true)
    AppraisalDepartmentSettingsController.any_instance.stubs(:authorize).returns(true)
    AppraisalEmployeeSettingsController.any_instance.stubs(:authorize).returns(true)
    AppraisalParticipatorsController.any_instance.stubs(:authorize).returns(true)
    AppraisalQuestionnairesController.any_instance.stubs(:authorize).returns(true)
    QuestionnaireTemplatesController.any_instance.stubs(:current_user).returns(user)

    @profile1 = create_profile
    @profile2 = create_profile
    @profile3 = create_profile
    @profile4 = create_profile
    @profile5 = create_profile
    @profile6 = create_profile

    @user1 = @profile1.user
    @user2 = @profile2.user
    @user3 = @profile3.user
    @user4 = @profile4.user
    @user5 = @profile5.user
    @user6 = @profile6.user

    @location1 = create(:location, chinese_name: '辦公室')
    @location2 = create(:location, chinese_name: '新葡京')

    @department1 = create(:department, chinese_name: '集团')
    @department2 = create(:department, chinese_name: '行政及人力資源部')
    @department3 = create(:department, chinese_name: '資訊科技部')

    @position1 = create(:position, chinese_name: '高級經理')
    @position2 = create(:position, chinese_name: 'IT员工')
    @position3 = create(:position, chinese_name: '市场调研员')

    @location1.departments << @department1
    @location1.departments << @department2
    @location1.departments << @department3
    @location2.departments << @department1
    @location2.departments << @department2
    @location2.departments << @department3

    @user1.location = @location1
    @user2.location = @location1
    @user3.location = @location1
    @user4.location = @location2
    @user5.location = @location2
    @user6.location = @location2

    @user1.department = @department1
    @user2.department = @department2
    @user3.department = @department3
    @user4.department = @department1
    @user5.department = @department2
    @user6.department = @department3

    @user1.position = @position1
    @user2.position = @position2
    @user3.position = @position3
    @user4.position = @position1
    @user5.position = @position2
    @user6.position = @position3

    @user1.grade = 1
    @user2.grade = 2
    @user3.grade = 3
    @user4.grade = 1
    @user5.grade = 2
    @user6.grade = 3

    @user1.save!
    @user2.save!
    @user3.save!
    @user4.save!
    @user5.save!
    @user6.save!

    AppraisalBasicSetting.load_predefined
    AppraisalDepartmentSetting.create_all_related_settings
    #AppraisalEmployeeSetting.generate

    AppraisalsController.any_instance.stubs(:current_user).returns(user)
    @user1.add_role(@admin_role)
    @user2.add_role(@admin_role)
    @user3.add_role(@admin_role)
    @user4.add_role(@admin_role)
    @user5.add_role(@admin_role)
    @user6.add_role(@admin_role)
    # AppraisalEmployeeSetting.test_preset
    @appraisal1 = create(:appraisal, appraisal_status: :unpublished,    appraisal_name: '公司員工2017年第一期評核', date_begin: '2017/01/01', date_end: '2017/01/15', participator_amount: 1000)
    @appraisal2 = create(:appraisal, appraisal_status: :to_be_assessed, appraisal_name: '公司員工2017年第二期評核', date_begin: '2017/04/01', date_end: '2017/04/15', participator_amount: 2000)
    @appraisal3 = create(:appraisal, appraisal_status: :assessing,      appraisal_name: '公司員工2017年第三期評核', date_begin: '2017/07/01', date_end: '2017/07/15', participator_amount: 3000)
    @appraisal4 = create(:appraisal, appraisal_status: :completed,      appraisal_name: '公司員工2017年第四期評核', date_begin: '2017/10/01', date_end: '2017/10/15', participator_amount: 4000,
                         ave_total_appraisal: 4, ave_superior_appraisal: 4, ave_colleague_appraisal: 4, ave_subordinate_appraisal: 4, ave_self_appraisal: 4)
    @appraisal5 = create(:appraisal, appraisal_status: :completed,      appraisal_name: '公司員工2017年第五期評核', date_begin: '2017/12/01', date_end: '2017/12/15', participator_amount: 5000,
                         ave_total_appraisal: 5, ave_superior_appraisal: 5, ave_colleague_appraisal: 5, ave_subordinate_appraisal: 5, ave_self_appraisal: 5)

    @appraisal_participator11 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user1.id, department_id: @department1.id)
    @appraisal_participator12 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user2.id, department_id: @department2.id)
    @appraisal_participator13 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user3.id, department_id: @department3.id)
    @appraisal_participator14 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user4.id, department_id: @department1.id)
    @appraisal_participator15 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user5.id, department_id: @department2.id)
    @appraisal_participator16 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user6.id, department_id: @department3.id)

    @appraisal_participator21 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user1.id, department_id: @department1.id)
    @appraisal_participator22 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user2.id, department_id: @department2.id)
    @appraisal_participator23 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user3.id, department_id: @department3.id)
    @appraisal_participator24 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user4.id, department_id: @department1.id)
    @appraisal_participator25 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user5.id, department_id: @department2.id)
    @appraisal_participator26 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user6.id, department_id: @department3.id)

    @appraisal_participator31 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user1.id, department_id: @department1.id)
    @appraisal_participator32 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user2.id, department_id: @department2.id)
    @appraisal_participator33 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user3.id, department_id: @department3.id)
    @appraisal_participator34 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user4.id, department_id: @department1.id)
    @appraisal_participator35 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user5.id, department_id: @department2.id)
    @appraisal_participator36 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user6.id, department_id: @department3.id)

    @appraisal_participator41 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user1.id, department_id: @department1.id)
    @appraisal_participator42 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user2.id, department_id: @department2.id)
    @appraisal_participator43 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user3.id, department_id: @department3.id)
    @appraisal_participator44 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user4.id, department_id: @department1.id)
    @appraisal_participator45 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user5.id, department_id: @department2.id)
    @appraisal_participator46 = create(:appraisal_participator, appraisal_id: @appraisal4.id, user_id: @user6.id, department_id: @department3.id)

    @appraisal_participator51 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user1.id, department_id: @department1.id)
    @appraisal_participator52 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user2.id, department_id: @department2.id)
    @appraisal_participator53 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user3.id, department_id: @department3.id)
    @appraisal_participator54 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user4.id, department_id: @department1.id)
    @appraisal_participator55 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user5.id, department_id: @department2.id)
    @appraisal_participator56 = create(:appraisal_participator, appraisal_id: @appraisal5.id, user_id: @user6.id, department_id: @department3.id)

    @questionnaire_template = create(:questionnaire_template)

    @questionnaire1 = create(:questionnaire, is_filled_in: true)
    @questionnaire1.questionnaire_template = @appraisal_template

    @appraisal_questionnaire1 = create(:appraisal_questionnaire)
    @appraisal_questionnaire1.questionnaire = @questionnaire1

    @appraisal1.appraisal_questionnaires << @appraisal_questionnaire1
    @appraisal2.appraisal_questionnaires << @appraisal_questionnaire1
    @appraisal3.appraisal_questionnaires << @appraisal_questionnaire1
    @appraisal4.appraisal_questionnaires << @appraisal_questionnaire1
    @appraisal5.appraisal_questionnaires << @appraisal_questionnaire1

  end

  def test_index
    get appraisals_url
    assert_response :success
    assert_equal json_res['data'].count, 4

    get appraisals_url, params: { appraisal_status: 'unpublished' }
    assert_response :success
    assert_equal json_res['data'].count, 1
    get appraisals_url, params: { sort_column: 'appraisal_status', sort_direction: 'desc' }
    assert_response :success
    assert json_res['data'].second['appraisal_status']>json_res['data'].third['appraisal_status']

    range_begin = '2017/01/01'
    range_end   = '2017/01/05'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get appraisals_url, params: { appraisal_date: range }
    assert_response :success
    assert_equal json_res['data'].count, 1
    assert json_res['data'].first['appraisal_date'].to_datetime >= Time.zone.parse(range[:begin])
    assert json_res['data'].first['appraisal_date'].to_datetime <= Time.zone.parse(range[:end])

    get appraisals_url, params: { participator_amount: [1000, 2000], sort_column: 'participator_amount', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['participator_amount']<json_res['data'].first['participator_amount']

    get appraisals_url, params: { ave_colleague_appraisal: [4,5], sort_column: 'ave_colleague_appraisal', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['ave_colleague_appraisal']<json_res['data'].first['ave_colleague_appraisal']

    get appraisals_url, params: { ave_total_appraisal: [4,5], sort_column: 'ave_total_appraisal', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['ave_total_appraisal']<json_res['data'].first['ave_total_appraisal']

    get appraisals_url, params: { ave_superior_appraisal: [4,5], sort_column: 'ave_superior_appraisal', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['ave_superior_appraisal']<json_res['data'].first['ave_superior_appraisal']

    get appraisals_url, params: { ave_subordinate_appraisal: [4,5], sort_column: 'ave_subordinate_appraisal', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['ave_subordinate_appraisal']<json_res['data'].first['ave_subordinate_appraisal']

    get appraisals_url, params: { ave_self_appraisal: [4,5], sort_column: 'ave_self_appraisal', sort_direction: 'desc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].second['ave_self_appraisal']<json_res['data'].first['ave_self_appraisal']

  end

  def test_index_by_department
    AppraisalsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_department_appraisals_url
    assert_response :success
    assert_equal 4, json_res['data'].count
  end

  def test_index_by_mine
    AppraisalsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_mine_appraisals_url
    assert_response :success
    assert_equal 4, json_res['data'].count
  end

  def test_options
    get options_appraisals_url
    assert_response :success
  end

  def test_create
    # 问卷相关
    params = {
      region: 'macau',
      chinese_name: '測試 1',
      english_name: 'test 1',
      simple_chinese_name: '测试 1',
      template_type: 'other',
      template_introduction: 'template_introduction',
      creator_id: @user1.id,
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
    post '/questionnaire_templates', params: params, as: :json
    assert_response :success
    # byebug
    # 创建基础设定相关文件
    attach = create(:attachment)
    attachment_params = {
      appraisal_basic_setting_id: AppraisalBasicSetting.first.id,
      attachment_id: attach.id,
      file_name: 'cecece',
      file_type: '封面',
      comment: Faker::Lorem.sentence
    }
    post appraisal_basic_setting_attachments_url, params: attachment_params
    assert_response :success
    # byebug
    attach = AppraisalBasicSetting.first.appraisal_attachments.last.reload
    assert_equal attach.file_name, 'cecece'
    assert_equal attach.file_type, '封面'
    assert_equal attach.comment, attachment_params[:comment]

    # 批量更新部门设定
    batch_update_params = {
      location_ids: [ @location1.id ],
      can_across_appraisal_grade: true,
      appraisal_mode_superior: 'assessed_by_part_of_the_superiors',
      appraisal_times_superior: 3,
      appraisal_mode_collegue: 'group_only',
      appraisal_times_collegue: 4,
      appraisal_mode_subordinate: 'part_of_the_superiors',
      appraisal_times_subordinate: 5,
      appraisal_grade_quantity_inside: 5,
      group_A_appraisal_template_id: QuestionnaireTemplate.last.id,
      group_B_appraisal_template_id: QuestionnaireTemplate.last.id,
      group_C_appraisal_template_id: QuestionnaireTemplate.last.id,
      group_D_appraisal_template_id: QuestionnaireTemplate.last.id,
      group_E_appraisal_template_id: QuestionnaireTemplate.last.id
    }
    patch batch_update_appraisal_department_settings_url, params: batch_update_params
    assert_response :success

    # AppraisalEmployeeSetting.test_preset

    # byebug
    # 创建360评核
    post appraisals_url, params: { appraisal: {
      appraisal_name: '公司員工2017年第四期評核',
      date_begin: '2017/01/01',
      date_end:   '2017/01/15',
      location:   [@location1.id, @location2.id],
      department: [@department1.id, @department2.id, @department3.id],
      position:   [@position1.id, @position2.id,  @position3.id],
      grade:      [2, 3, 5],
      date_of_employment: { begin: '2000/01/01', end: '2099/01/01' }
    } }, as: :json
    assert_response :success
    post appraisals_url, params: { appraisal: {
        appraisal_name: '公司員工2017年第四期評核',
        date_begin: '2017/01/01',
        date_end:   '2016/01/15',
        location:   [@location1.id, @location2.id],
        department: [@department1.id, @department2.id, @department3.id],
        position:   [@position1.id, @position2.id,  @position3.id],
        grade:      [2, 3, 5],
        date_of_employment: { begin: '2000/01/01', end: '2099/01/01' }
    } }, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '時間不符合規則'
    post appraisals_url, params: { appraisal: {
        #appraisal_name: '公司員工2017年第四期評核',
        date_begin: '2017/01/01',
        date_end:   '2016/01/15',
        location:   [@location1.id, @location2.id],
        department: [@department1.id, @department2.id, @department3.id],
        position:   [@position1.id, @position2.id,  @position3.id],
        grade:      [2, 3, 5],
        date_of_employment: { begin: '2000/01/01', end: '2099/01/01' }
    } }, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
    # byebug
    appraisal = Appraisal.last

    #assert_equal appraisal['appraisal_attachments'].count, 1
    # 评核人员名单
    get appraisal_appraisal_participators_url(appraisal_id: appraisal['id']), params: { ask_for: 'candidates', by_whom: 'hr' }, as: :json
    assert_response :success
    # byebug
    appraisal_participators = appraisal.appraisal_participators
    assert_equal appraisal_participators.count, 6
    # byebug
    # 自动分配
    post auto_assign_appraisal_appraisal_participators_url(appraisal_id: appraisal['id'])
    assert_response :success
    # byebug
    # 评核问卷
    post appraisal_appraisal_questionnaires_url(appraisal_id: appraisal['id'])
    assert_response :success
    # byebug
    # 未填写问卷
    get not_filled_in_appraisal_appraisal_questionnaires_url(appraisal_id: appraisal['id'])
    assert_response :success
    # byebug
    get columns_appraisal_appraisal_questionnaires_url(appraisal_id: appraisal['id'])
    assert_response :success
    byebug
  end

  def test_show
    get appraisal_url(@appraisal1.id)
    assert_response :success
  end

  def test_update
    patch appraisal_url(@appraisal1.id), params: {
      appraisal_status: 'assessing'
    }
    assert_response :success
    assert_equal 'assessing', Appraisal.find(@appraisal1.id).appraisal_status
  end

  def test_destory
    assert_difference('Appraisal.count', -1) do
      delete appraisal_url(@appraisal1.id)
    end
    assert_response :success
  end

  def test_performance_interview_check
    get performance_interview_check_appraisal_url(@appraisal1.id), as: :json
    assert_response :success
    assert_equal json_res['performace_interview'], false
    assert_equal json_res['message'], 'status not matched.'
    get performance_interview_check_appraisal_url(@appraisal3.id), as: :json
    assert_response :success
    assert_equal json_res['performace_interview'], true
  end

  def test_performance_interview
    post performance_interview_appraisal_url(@appraisal1.id)
    assert_response :success
    assert_equal json_res['performace_interview'], false
    assert_equal json_res['message'], 'status not matched.'
    assert_equal PerformanceInterview.all.count, 0
    post performance_interview_appraisal_url(@appraisal4.id)
    assert_response :success
    assert_equal Appraisal.find(@appraisal4.id).appraisal_status, 'performance_interview'
    assert_equal PerformanceInterview.all.count, 6
  end

  def test_can_create
    AppraisalEmployeeSetting.any_instance.stubs(:current_user).returns(@user1)
    appraisal_department_setting = create(:appraisal_department_setting)
    appraisal_group = create(:appraisal_group)
    params = {
        user_id: @user1.id,
        appraisal_department_setting_id: appraisal_department_setting.id,
        appraisal_group_id: appraisal_group.id,
        level_in_department: 1,
        has_finished: true
    }
    post can_create_appraisals_url, as: :json, params: params
    assert_response :success
    assert_equal json_res['can_create'], true
  end

  def test_complete_or_no
    get complete_or_no_appraisal_url(@appraisal3.id), as: :json
    assert_response :success
    assert_equal json_res['complete_questionnaire'], true
    get complete_or_no_appraisal_url(@appraisal3.id), as: :json
    assert_response :success
    assert_equal json_res['complete_questionnaire'], false
  end

  def test_complete
    post complete_appraisal_url(@appraisal1.id)
    assert_response :success
    assert_equal json_res['complete'], false
    assert_equal json_res['message'], '评核状态不符合 评核中'
    post complete_appraisal_url(@appraisal3.id)
    assert_response :success
    assert_equal 'completed', Appraisal.find(@appraisal3.id).appraisal_status
    assert_equal Appraisal.find(@appraisal3.id).appraisal_reports.count, 6
  end

  # 评核总流程
  def test_appraisal_all
    # 创建一个问卷模板
    questionnaire_template_params = {
        region: 'macau',
        chinese_name: '測試 1',
        english_name: 'test 1',
        simple_chinese_name: '测试 1',
        template_type: 'other',
        template_introduction: 'template_introduction',
        creator_id: @user1.id,
        comment: 'test comment',

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
            }
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
                    }
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
    post '/questionnaire_templates', params: questionnaire_template_params, as: :json
    assert_response :success
    questionnaire_template = QuestionnaireTemplate.last

    # 基础设定
    AppraisalAttachmentsController.any_instance.stubs(:current_user).returns(@user1)
    attach = create(:attachment)
    attachment_params = {
        appraisal_basic_setting_id: AppraisalBasicSetting.first.id,
        attachment_id: attach.id,
        file_name: 'Fengmian',
        file_type: '封面',
        comment: Faker::Lorem.sentence
    }
    post appraisal_basic_setting_attachments_url, params: attachment_params
    assert_response :success
    attach = AppraisalBasicSetting.first.appraisal_attachments.last.reload
    assert_equal attach.file_name, 'Fengmian'
    assert_equal attach.file_type, '封面'
    assert_equal attach.comment, attachment_params[:comment]

    # 更新部门设定
    appraisal_department_params = {
        location_ids: @location1.id,
        can_across_appraisal_grade: true,
        appraisal_mode_superior: 'assessed_by_part_of_the_superiors',
        appraisal_times_superior: 3,
        appraisal_mode_collegue: 'group_only',
        appraisal_times_collegue: 4,
        appraisal_mode_subordinate: 'part_of_the_superiors',
        appraisal_times_subordinate: 5,
        appraisal_grade_quantity_inside: 5,
        group_A_appraisal_template_id: QuestionnaireTemplate.last.id,
        group_B_appraisal_template_id: QuestionnaireTemplate.last.id,
        group_C_appraisal_template_id: QuestionnaireTemplate.last.id,
        group_D_appraisal_template_id: QuestionnaireTemplate.last.id,
        group_E_appraisal_template_id: QuestionnaireTemplate.last.id
    }
    patch batch_update_appraisal_department_settings_url, params: appraisal_department_params
    assert_response :success

    # 更新员工设定
    AppraisalEmployeeSetting.generate
    appraisal_employee_params = {
        appraisal_group_id: nil,
        level_in_department: 3
    }
    patch appraisal_employee_setting_url(AppraisalEmployeeSetting.first.id), params: appraisal_employee_params
    assert_response :success

    # 创建360评核
    post appraisals_url, params: {
        appraisal_name: '公司員工2018年第1期評核',
        date_begin: '2018/01/01',
        date_end:   '2018/01/15',
        location:   @location1.id,
        department: @department1.id,
        position:   [@position1.id, @position2.id,  @position3.id],
        grade:      [2, 3, 1],
        date_of_employment: { begin: '2000/01/01', end: '2099/01/01' }
    } , as: :json
    assert_response :success
    appraisal = Appraisal.last

    # 评核人员名单
    post appraisal_appraisal_participators_url(appraisal_id: appraisal['id']), params: {user_ids: @user1.id}
    assert_response :success
    get appraisal_appraisal_participators_url(appraisal_id: appraisal['id']), params: { ask_for: 'candidates', by_whom: 'hr' }, as: :json
    assert_response :success
    appraisal_participator = AppraisalParticipator.last

    # 创建评核人
    assess_relationship1_params = {
        assess_type: 'superior_assess',
        appraisal_id: appraisal.id,
        appraisal_participator_id: appraisal_participator.id,
        assessor_id: @user5.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id: appraisal['id'], id: appraisal_participator['id']), as: :json, params: assess_relationship1_params
    assert_response :success

    assess_relationship2_params = {
        assess_type: 'colleague_assess',
        appraisal_id: appraisal.id,
        appraisal_participator_id: appraisal_participator.id,
        assessor_id: @user4.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id: appraisal['id'], id: appraisal_participator['id']), as: :json, params: assess_relationship2_params
    assert_response :success

    assess_relationship3_params = {
        assess_type: 'colleague_assess',
        appraisal_id: appraisal.id,
        appraisal_participator_id: appraisal_participator.id,
        assessor_id: @user3.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id: appraisal['id'], id: appraisal_participator['id']), as: :json, params: assess_relationship3_params
    assert_response :success

    assess_relationship4_params = {
        assess_type: 'colleague_assess',
        appraisal_id: appraisal.id,
        appraisal_participator_id: appraisal_participator.id,
        assessor_id: @user2.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id: appraisal['id'], id: appraisal_participator['id']), as: :json, params: assess_relationship4_params
    assert_response :success

    assess_relationship5_params = {
        assess_type: 'subordinate_assess',
        appraisal_id: appraisal.id,
        appraisal_participator_id: appraisal_participator.id,
        assessor_id: @user6.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id: appraisal['id'], id: appraisal_participator['id']), as: :json, params: assess_relationship5_params
    assert_response :success

    # 公布评核
    patch appraisal_url(appraisal['id']), params: {appraisal_status: 'to_be_accessed'}
    assert_response :success

    # 发起评核
    post initiate_appraisal_url(@appraisal1)
    assert_response :success
    assert_equal json_res['meet_the_number_conditions'], false
    assert_equal json_res['message'], '评核状态不符合 待评核'
    post initiate_appraisal_url(appraisal)
    assert_response :success
    assert_equal appraisal['appraisal_status'], 'assessing'
    assert_equal json_res['data'].count, 6
    assert_equal Questionnaire.all.count, 6
    questionnaire_id = AppraisalQuestionnaire.find(assessor_id: @user6.id).questionnaire_id
    questionnaire_id1 = AppraisalQuestionnaire.find(assessor_id: @user5.id).questionnaire_id


    # 填写评核问卷
    appraisal_questionnaire_params = {
        questionnaire_id: questionnaire_id,

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                value: 10,
                score: 5,
                annotation: 'as',
                right_answer: 'hh',
                is_required: true,
                answer: 'answer 1',
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                value: 10,
                score: 5,
                annotation: 'gg',
                right_answer: [1, 1],
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
                ],
            },
        ],

        matrix_single_choice_questions: [
            {
                order_no: 1,
                title: 'matrix question 3',
                value: 10,
                score: 5,
                annotation: 10,
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
    patch save_appraisal_appraisal_questionnaires_url(appraisal), params: appraisal_questionnaire_params, as: :json
    assert_response :success
    assert_equal json_res['success'], true

    post can_submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: questionnaire_id }
    assert_response :success
    assert_equal json_res['can_submit'], true
    assert_equal Questionnaire.find(questionnaire_id).is_filled_in, true
    assert_equal Questionnaire.find(questionnaire_id).submit_date, Time.zone.now
    post can_submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: 123 }
    assert_response 422
    assert_equal json_res['data'][0]['message'], '问卷不存在'
    post can_submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: questionnaire_id1 }
    assert_response :success
    assert_equal json_res['can_submit'], false
    assert_equal Questionnaire.find(questionnaire_id1).is_filled_in, false
    post can_submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: 123 }
    assert_response 422
    assert_equal json_res['data'][0]['message'], '问卷不存在'

    patch submit_appraisal_appraisal_questionnaires_url(appraisal), params: {questionnaire_id: questionnaire_id}
    assert_response :success
    assert_equal json_res['success'], true
    patch submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: 123 }
    assert_response 422
    assert_equal json_res['data'][0]['message'], '问卷不存在'
    patch submit_appraisal_appraisal_questionnaires_url(appraisal), params: {questionnaire_id: questionnaire_id}
    assert_response :success
    assert_equal json_res['can_submit'], false
    patch submit_appraisal_appraisal_questionnaires_url(appraisal), as: :json, params: { questionnaire_id: 123 }
    assert_response 422
    assert_equal json_res['data'][0]['message'], '问卷不存在'

    get not_filled_participators_appraisal_appraisal_participators_url(appraisal)
    assert_response :success
    assert_equal json_res['data'].count, 4

    # 完成评核,生成评核报告
    post complete_appraisal_url(appraisal)
    assert_response :success
    assert_equal appraisal['appraisal_status'], 'completed'
    assert_equal json_res.count, 1
    assert_equal json_res.first['overall_score'], 1.25

    # 发起绩效面谈
    post performance_interview_appraisal_url(appraisal)
    assert_response :success
    assert_equal appraisal['appraisal_status'], 'performance_interview'
    assert_equal appraisal['release_interviews'], true
    assert_equal json_res.count, 1
    attachment = create(:attachment)
    performance_interview_params = {
        performance_moderator_id: @user2.id,
        interview_date: '2017/12/12',
        interview_time_begin: '12:12',
        interview_time_end: '12:30',
        operator_id: @user2.id,
        operator_at: '2017/12/12',
        file_name: 'haha',
        attachment_id: attachment.id,
        creator_id: @user2.id
    }
    patch completed_appraisal_performance_interviews(appraisal), params: performance_interview_params
    assert_response :success
    assert_equal json_res['data'][0]['interview_date'], '2017/12/12'
    assert_equal json_res['data'][0]['operator_id'], @user2.id
    assert_equal json_res['data'][0]['performance_moderator_id'], @user2.id
    assert_equal json_res['data'][0]['attachment_items'][0]['file_name'], 'haha'
    assert_equal json_res['data'][0]['attachment_items'][0]['attachment_id'], attachment.id
    assert_equal json_res['data'][0]['attachment_items'][0]['creator_id'], @user2.id


  end

end
