require 'test_helper'

class AppraisalReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    seaweed_webmock
    AppraisalAttachmentsController.any_instance.stubs(:authorize).returns(true)
    AppraisalReportsController.any_instance.stubs(:authorize).returns(true)
    AppraisalEmployeeSettingsController.any_instance.stubs(:authorize).returns(true)
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
    AppraisalReportsController.any_instance.stubs(:current_user).returns(@user1)

    @location = create(:location, chinese_name: '辦公室')

    @department = create(:department, chinese_name: '行政及人力資源部')

    @position1 = create(:position, chinese_name: '高級經理')
    @position2 = create(:position, chinese_name: 'IT员工')
    @position3 = create(:position, chinese_name: '市场调研员')

    @location.departments << @department

    @user1.location = @location1
    @user2.location = @location1
    @user3.location = @location1
    @user4.location = @location1
    @user5.location = @location1
    @user6.location = @location1

    @user1.department = @department
    @user2.department = @department
    @user3.department = @department
    @user4.department = @department
    @user5.department = @department
    @user6.department = @department

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

    @appraisal1 = create(:appraisal, appraisal_status: :completed,  complete_questionnaire: true,    appraisal_name: '公司員工2017年第四期評核', date_begin: '2017/10/01', date_end: '2017/10/15', participator_amount: 2000)
    @appraisal2 = create(:appraisal, appraisal_status: :completed,  complete_questionnaire: true,    appraisal_name: '公司員工2017年第五期評核', date_begin: '2017/12/01', date_end: '2017/12/15', participator_amount: 2000)

    @appraisal_participator1 = create(:appraisal_participator, appraisal_id: @appraisal1.id, user_id: @user1.id)
    @appraisal_participator2 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user1.id)

    @assess_relationship1 = create(:assess_relationship, assess_type: 'superior_assess', appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id, assessor_id: @user2.id)
    @assess_relationship2 = create(:assess_relationship, assess_type: 'colleague_assess', appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id, assessor_id: @user3.id)
    @assess_relationship3 = create(:assess_relationship, assess_type: 'colleague_assess', appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id, assessor_id: @user4.id)
    @assess_relationship4 = create(:assess_relationship, assess_type: 'colleague_assess', appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id, assessor_id: @user5.id)
    @assess_relationship5 = create(:assess_relationship, assess_type: 'subordinate_assess', appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id, assessor_id: @user6.id)

    @appraisal_template = create(:questionnaire_template)

    @questionnaire = create(:questionnaire, questionnaire_template_id: @appraisal_template.id, is_filled_in: true)

    @appraisal_questionnaire2 = create(:appraisal_questionnaire,
                                       appraisal_id: @appraisal1.id,
                                       appraisal_participator_id: @appraisal_participator1.id,
                                       questionnaire_id: @questionnaire.id,
                                       assessor_id: @user2.id,
                                       assess_type: 'superior_assess',
                                       final_score: 3,
                                       submit_date:'2017/12/12')
    @appraisal_questionnaire3 = create(:appraisal_questionnaire,
                                       appraisal_id: @appraisal1.id,
                                       appraisal_participator_id: @appraisal_participator1.id,
                                       questionnaire_id: @questionnaire.id,
                                       assess_type: 'colleague_assess',
                                       final_score: 3,
                                       assessor_id: @user3.id,
                                       submit_date:'2017/12/12')
    @appraisal_questionnaire4 = create(:appraisal_questionnaire,
                                       appraisal_id: @appraisal1.id,
                                       appraisal_participator_id: @appraisal_participator1.id,
                                       questionnaire_id: @questionnaire.id,
                                       assessor_id: @user4.id,
                                       assess_type: 'colleague_assess',
                                       final_score: 3,
                                       submit_date:'2017/12/12')
    @appraisal_questionnaire5 = create(:appraisal_questionnaire,
                                       appraisal_id: @appraisal1.id,
                                       appraisal_participator_id: @appraisal_participator1.id,
                                       questionnaire_id: @questionnaire.id,
                                       assessor_id: @user5.id,
                                       assess_type: 'colleague_assess',
                                       final_score: 3,
                                       submit_date:'2017/12/12')
    @appraisal_questionnaire6 = create(:appraisal_questionnaire,
                                       appraisal_id: @appraisal1.id,
                                       appraisal_participator_id: @appraisal_participator1.id,
                                       questionnaire_id: @questionnaire.id,
                                       assessor_id: @user6.id,
                                       assess_type: 'subordinate_assess',
                                       final_score: 3,
                                       submit_date:'2017/12/12')

    create(:appraisal_report, appraisal_id: @appraisal1.id, appraisal_participator_id: @appraisal_participator1.id)
  end

  def test_index
    AppraisalsController.any_instance.stubs(:authorize).returns(true)
    post complete_appraisal_url(@appraisal1), as: :json
    assert_response :success
    assert_equal AppraisalReport.all.count, 2
    appraisalreport = AppraisalReport.last
    assert_equal appraisalreport['overall_score'], 3
    assert_equal appraisalreport['superior_score'], 3
    assert_equal appraisalreport['colleague_score'], 3
    assert_equal appraisalreport['subordinate_score'], 3
    get appraisal_appraisal_reports_url(@appraisal1), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2
  end

  def test_index_by_department
    AppraisalReportsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_department_appraisal_appraisal_reports_url(appraisal_id: @appraisal1.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_index_by_mine
    AppraisalReportsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_mine_appraisal_appraisal_reports_url(appraisal_id: @appraisal1.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_columns
    get columns_appraisal_appraisal_reports_url(@appraisal1)
    assert_response :success
  end

  def test_options
    get options_appraisal_appraisal_reports_url(@appraisal1)
    assert_response :success
  end

  def test_record_index
    AppraisalReportsController.any_instance.stubs(:current_user).returns(@user1)
    get appraisal_records_appraisal_reports_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2
    AppraisalReportsController.any_instance.stubs(:search_query).returns(AppraisalReport.all)
    get "/appraisal_records/appraisal_reports/records.xlsx"
    assert_response :success
  end

  def test_record_columns
    get appraisal_records_appraisal_reports_columns_url
    assert_response :success
  end

  def test_record_options
    get appraisal_records_appraisal_reports_options_url
    assert_response :success
  end
end
