require 'test_helper'

class PerformanceInterviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    seaweed_webmock
    AppraisalAttachmentsController.any_instance.stubs(:authorize).returns(true)
    AppraisalsController.any_instance.stubs(:authorize).returns(true)
    PerformanceInterviewsController.any_instance.stubs(:authorize).returns(true)
    AppraisalParticipatorsController.any_instance.stubs(:authorize).returns(true)
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

    AppraisalAttachmentsController.any_instance.stubs(:current_user).returns(@user1)
    AppraisalQuestionnairesController.any_instance.stubs(:current_user).returns(@user1)

    @location1 = create(:location, chinese_name: '辦公室')
    @location2 = create(:location, chinese_name: '新葡京')

    @department0 = create(:department, chinese_name: '集团')
    @department1 = create(:department, chinese_name: '行政及人力資源部')
    @department2 = create(:department, chinese_name: '資訊科技部')
    @department3 = create(:department, chinese_name: '市場策劃部')

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
    @user4.location = @location1
    @user5.location = @location1
    @user6.location = @location1

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

    @user1.grade = 2
    @user2.grade = 2
    @user3.grade = 2
    @user4.grade = 3
    @user5.grade = 3
    @user6.grade = 3

    @user1.save!
    @user2.save!
    @user3.save!
    @user4.save!
    @user5.save!
    @user6.save!

    AppraisalBasicSetting.load_predefined
    AppraisalDepartmentSetting.create_all_related_settings
    AppraisalEmployeeSetting.generate
    @appraisal_employee = create(:appraisal_employee_setting, user_id: @user1.id)
    @appraisal_employee.get_appraisal_record_details

    @appraisal1 = create(:appraisal, appraisal_status: :to_be_assessed, appraisal_name: '公司員工2017年第二期評核', date_begin: '2017/04/01', date_end: '2017/04/15', participator_amount: 2000)
    @appraisal2 = create(:appraisal, appraisal_status: :assessing,      appraisal_name: '公司員工2017年第三期評核', date_begin: '2017/07/01', date_end: '2017/07/15', participator_amount: 1000)
    @appraisal3 = create(:appraisal, appraisal_status: :completed,      appraisal_name: '公司員工2017年第四期評核', date_begin: '2017/10/01', date_end: '2017/10/15', participator_amount: 2000)

    @appraisal_participator1 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user1.id)
    @appraisal_participator2 = create(:appraisal_participator, appraisal_id: @appraisal3.id, user_id: @user1.id)

    create(:performance_interview, appraisal_id: @appraisal2.id, appraisal_participator_id: @appraisal_participator1.id, interview_date: '2017/10/10', interview_time_begin: '14:00', interview_time_end: '15:00', operator_id: @user2.id, performance_moderator_id: @user3.id)
    @performance_interview = create(:performance_interview, appraisal_id: @appraisal3.id, appraisal_participator_id: @appraisal_participator2.id, interview_date: '2017/10/10', interview_time_begin: '14:00', interview_time_end: '15:00', operator_id: @user2.id, performance_moderator_id: @user3.id)

  end

  def test_index
    get appraisal_performance_interviews_url(@appraisal3), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
    get appraisal_performance_interviews_url(@appraisal2), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_update
    AppraisalsController.any_instance.stubs(:current_user).returns(@user2)
    PerformanceInterviewsController.any_instance.stubs(:current_user).returns(@user2)
    params = {
        interview_date: '2017/10/10',
        interview_time_begin: '16:00',
        interview_time_end: '17:00',
        operator_id: @user2.id,
        performance_moderator_id: @user4.id
    }
    patch appraisal_performance_interview_url(appraisal_id: @appraisal3.id, id: @performance_interview.id), as: :json, params: params
    assert_response 200
    params = {
        interview_date: '2017/10/10',
        interview_time_begin: '16:00',
        interview_time_end: '17:00',
        operator_id: @user2.id,
        performance_moderator_id: @user1.id
    }
    patch appraisal_performance_interview_url(appraisal_id: @appraisal3.id, id: @performance_interview.id), as: :json, params: params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '面談主持人不能是自己'
    params = {
        interview_date: '2017/10/10',
        interview_time_begin: '16:00',
        interview_time_end: '15:00',
        operator_id: @user2.id,
        performance_moderator_id: @user4.id
    }
    patch appraisal_performance_interview_url(appraisal_id: @appraisal3.id, id: @performance_interview.id), as: :json, params: params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '時間不符合規則'
    params = {
        #interview_date: '2017/10/10',
        interview_time_begin: '16:00',
        interview_time_end: '17:00',
        operator_id: @user2.id,
        performance_moderator_id: @user4.id
    }
    patch appraisal_performance_interview_url(appraisal_id: @appraisal3.id, id: @performance_interview.id), as: :json, params: params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

  end

  def test_index_by_department
    AppraisalsController.any_instance.stubs(:current_user).returns(@user1)
    PerformanceInterviewsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_department_appraisal_performance_interviews_url(appraisal_id: @appraisal3.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_index_by_mine
    AppraisalsController.any_instance.stubs(:current_user).returns(@user1)
    PerformanceInterviewsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_mine_appraisal_performance_interviews_url(appraisal_id: @appraisal3.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_columns
    get columns_appraisal_performance_interviews_url(@appraisal3)
    assert_response :success
  end

  def test_options
    get options_appraisal_performance_interviews_url(@appraisal3)
    assert_response :success
  end

  def test_record_index
    AppraisalsController.any_instance.stubs(:current_user).returns(@user1)
    PerformanceInterviewsController.any_instance.stubs(:current_user).returns(@user1)
    get appraisal_records_performance_interviews_records_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2
    AppraisalQuestionnairesController.any_instance.stubs(:search_query).returns(AppraisalQuestionnaire.all)
    get "/appraisal_records/performance_interviews/records.xlsx"
    assert_response :success
  end

  def test_record_columns
    get appraisal_records_performance_interviews_columns_url
    assert_response :success
  end

  def test_record_options
    get appraisal_records_performance_interviews_options_url
    assert_response :success
  end

end
