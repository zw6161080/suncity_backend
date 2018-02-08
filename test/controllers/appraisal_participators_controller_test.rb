require 'test_helper'

class AppraisalParticipatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    AppraisalBasicSetting.load_predefined
    AppraisalParticipatorsController.any_instance.stubs(:authorize).returns(true)
    AppraisalParticipatorsController.any_instance.stubs(:current_user).returns(@user1)
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

    @appraisal = create(:appraisal, appraisal_status: :unpublished, appraisal_name: '公司員工2017年第一期評核', date_begin: '2017/01/01', date_end: '2017/01/15', participator_amount: 1000)
    @appraisal2 = create(:appraisal, appraisal_status: :unpublished, appraisal_name: '公司員工2017年第二期評核', date_begin: '2017/01/01', date_end: '2017/01/15', participator_amount: 1000)

    @appraisal_department_setting = create(:appraisal_department_setting,
                                           location_id: @location1.id,
                                           department_id: @department1.id,
                                           appraisal_basic_setting_id: AppraisalBasicSetting.first.id,
                                           can_across_appraisal_grade: false,
                                           appraisal_mode_superior: nil,
                                           appraisal_times_superior: 3,
                                           appraisal_mode_collegue: nil,
                                           appraisal_times_collegue: 3,
                                           appraisal_mode_subordinate: nil,
                                           appraisal_times_subordinate: 3,
                                           appraisal_grade_quantity_inside: 3,
                                           whether_group_inside: false
    )
    @appraisal_department_setting2 = create(:appraisal_department_setting,
                                           location_id: @location1.id,
                                           department_id: @department2.id,
                                           appraisal_basic_setting_id: AppraisalBasicSetting.first.id,
                                           can_across_appraisal_grade: false,
                                           appraisal_mode_superior: nil,
                                           appraisal_times_superior: 3,
                                           appraisal_mode_collegue: nil,
                                           appraisal_times_collegue: 3,
                                           appraisal_mode_subordinate: nil,
                                           appraisal_times_subordinate: 3,
                                           appraisal_grade_quantity_inside: 3,
                                           whether_group_inside: false
    )
    @appraisal_department_setting3 = create(:appraisal_department_setting,
                                           location_id: @location1.id,
                                           department_id: @department3.id,
                                           appraisal_basic_setting_id: AppraisalBasicSetting.first.id,
                                           can_across_appraisal_grade: false,
                                           appraisal_mode_superior: nil,
                                           appraisal_times_superior: 3,
                                           appraisal_mode_collegue: nil,
                                           appraisal_times_collegue: 3,
                                           appraisal_mode_subordinate: nil,
                                           appraisal_times_subordinate: 3,
                                           appraisal_grade_quantity_inside: 3,
                                           whether_group_inside: false
    )


    @appraisal_employee_setting1 = create(:appraisal_employee_setting, user_id: @user1.id, has_finished: true, level_in_department: 1)
    @appraisal_employee_setting2 = create(:appraisal_employee_setting, user_id: @user2.id, has_finished: true, level_in_department: 1)
    @appraisal_employee_setting3 = create(:appraisal_employee_setting, user_id: @user3.id, has_finished: true, level_in_department: 1)
    @appraisal_employee_setting4 = create(:appraisal_employee_setting, user_id: @user4.id, has_finished: true, level_in_department: 1)
    @appraisal_employee_setting5 = create(:appraisal_employee_setting, user_id: @user5.id, has_finished: true, level_in_department: 2)
    @appraisal_employee_setting6 = create(:appraisal_employee_setting, user_id: @user6.id, has_finished: true, level_in_department: 3)

    @appraisal_participator1 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user1.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting1.id, appraisal_grade: 1)
    @appraisal_participator2 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user2.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting2.id, appraisal_grade: 2)
    @appraisal_participator3 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user3.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting3.id, appraisal_grade: 3)
    @appraisal_participator4 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user4.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting4.id, appraisal_grade: 1)
    @appraisal_participator5 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user5.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting5.id, appraisal_grade: 2)
    @appraisal_participator6 = create(:appraisal_participator, appraisal_id: @appraisal.id, user_id: @user6.id, appraisal_department_setting_id: @appraisal_department_setting.id, appraisal_employee_setting_id: @appraisal_employee_setting6.id, appraisal_grade: 3)

    @appraisal_participator11 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user1.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting1.id, appraisal_grade: 1)
    @appraisal_participator22 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user2.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting2.id, appraisal_grade: 2)
    @appraisal_participator33 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user3.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting3.id, appraisal_grade: 3)
    @appraisal_participator44 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user4.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting4.id, appraisal_grade: 1)
    @appraisal_participator55 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user5.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting5.id, appraisal_grade: 2)
    @appraisal_participator66 = create(:appraisal_participator, appraisal_id: @appraisal2.id, user_id: @user6.id, appraisal_department_setting_id: @appraisal_department_setting2.id, appraisal_employee_setting_id: @appraisal_employee_setting6.id, appraisal_grade: 3)


  end

  def test_index
    # division_of_job date_of_employment未测试
    get appraisal_appraisal_participators_url(@appraisal) , as: :json
    assert_response :success
    assert_equal json_res['data'].count, 6
  end

  def test_can_add_to_list
    get can_add_to_participator_list_appraisal_appraisal_participators_url(@appraisal), params: { user_ids: [@user1.id, @user2.id, @user3.id] }
    assert_response :success
    assert_equal json_res['can_create'], false
    assert_equal json_res['not_match_users'].count, 2

    get can_add_to_participator_list_appraisal_appraisal_participators_url(@appraisal), params: { }
    assert_response :success

    get can_add_to_participator_list_appraisal_appraisal_participators_url(@appraisal), params: { user_ids: [@user3.id] }
    assert_response :success

    assert_equal json_res['can_create'], true
  end

  def test_index_by_department
    AppraisalParticipatorsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_department_appraisal_appraisal_participators_url(appraisal_id: @appraisal.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2
  end

  def test_index_by_mine
    AppraisalParticipatorsController.any_instance.stubs(:current_user).returns(@user1)
    get index_by_mine_appraisal_appraisal_participators_url(appraisal_id: @appraisal.id), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_create
    user = create(:user, location_id: @location1.id, department_id: @department1.id, position_id: @position1.id)
    assert_difference('AppraisalParticipator.count', 1) do
      params = { appraisal_id: @appraisal.id,
                 user_id: user.id,
                 appraisal_department_setting_id: @appraisal_department_setting.id,
                 appraisal_grade: 1}
      post appraisal_appraisal_participators_url(@appraisal), as: :json, params: params
    end
    assert_response :success
    ap = AppraisalParticipator.last
    assert_equal ap['user']['empoid'], user.empoid
    assert_equal ap['user']['chinese_name'], user.chinese_name
    assert_equal ap['user']['department']['id'], user.department_id
    assert_equal ap['user']['location']['id'],  user.location_id
    assert_equal ap['user']['position']['id'], user.position_id
    assert_equal ap['user']['profile']['data']['position_information']['field_values']['division_of_job'], user.profile.data['position_information']['field_values']['division_of_job']
    assert_equal ap['user']['profile']['data']['position_information']['field_values']['date_of_employment'], user.profile.data['position_information']['field_values']['date_of_employment']
  end

  # POST /appraisals/:appraisal_id/appraisal_participators/auto_assign
  def test_auto_assign
    post auto_assign_appraisal_appraisal_participators_url(@appraisal), as: :json
    assert_response :success
    assert_equal json_res['auto_assign'], true
    assert_equal json_res['department_setting'], true
    assert_equal json_res['employee_setting'], true
    assert_equal @appraisal.assess_relationships.count, 36
    assert_equal @appraisal.assess_relationships.where(appraisal_participator_id: @appraisal_participator1.id).count, 6
    assert_equal @appraisal.assess_relationships.where(appraisal_participator_id: @appraisal_participator1.id).where(assess_type: "colleague_assess").count, 3
    assert_equal @appraisal.assess_relationships.where(appraisal_participator_id: @appraisal_participator1.id).where(assess_type: "colleague_assess").pluck(:assessor_id), [@user2.id, @user3.id, @user4.id]
    assert_equal @appraisal.assess_relationships.where(appraisal_participator_id: @appraisal_participator1.id).where(assess_type: "superior_assess").pluck(:assessor_id), [@user5.id, @user6.id]
    assert_equal @appraisal.assess_relationships.where(appraisal_participator_id: @appraisal_participator1.id).where(assess_type: "self_assess").pluck(:assessor_id), [@user1.id]
    post auto_assign_appraisal_appraisal_participators_url(@appraisal2), as: :json
    assert_response :success
    assert_equal json_res['auto_assign'], false
    assert_equal json_res['department_setting'], false
    assert_equal json_res['employee_setting'], true

  end

  def test_options
    get options_appraisal_participators_url
    assert_response :success
  end

  # DELETE /appraisals/:appraisal_id/appraisal_participators/:id
  def test_destroy
    assert_difference('AppraisalParticipator.count', -1) do
      delete appraisal_appraisal_participator_url(@appraisal.id, @appraisal_participator3.id)
    end
    assert_response :success
  end

  def test_create_assessor
    assess_relationship_params = {
        assess_type: 'superior_assess',
        appraisal_id: @appraisal.id,
        appraisal_participator_id: @appraisal_participator1.id,
        assessor_id: @user5.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id:@appraisal, id:@appraisal_participator1.id), as: :json, params: assess_relationship_params
    assert_response :success
    assert_equal json_res.count, 1
    assert_equal json_res['assess_type'], 'superior_assess'
    assert_equal json_res['appraisal_id'], @appraisal.id
    assert_equal json_res['appraisal_participator_id'], @appraisal_participator1.id
    assert_equal json_res['assessor_id'], @user5.id
    assess_relationship_params = {
        assess_type: 'superior_assess',
        appraisal_id: @appraisal.id,
        appraisal_participator_id: @appraisal_participator1.id,
        assessor_id: @user5.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id:@appraisal, id:@appraisal_participator1.id), as: :json, params: assess_relationship_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '同一个评核不能出现相同的评核者'
    assess_relationship_params = {
        #assess_type: 'superior_assess',
        appraisal_id: @appraisal.id,
        appraisal_participator_id: @appraisal_participator1.id,
        assessor_id: @user5.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id:@appraisal, id:@appraisal_participator1.id), as: :json, params: assess_relationship_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
    assess_relationship_params = {
        assess_type: 'superior_assess',
        appraisal_id: @appraisal.id,
        appraisal_participator_id: @appraisal_participator1.id,
        assessor_id: @user1.id
    }
    post create_assessor_appraisal_appraisal_participator_url(appraisal_id:@appraisal, id:@appraisal_participator1.id), as: :json, params: assess_relationship_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '非自我评核中不能出现本人'

  end

  def test_destory_assessor
    create(:assess_relationship,
           assess_type: 'superior_assess',
           appraisal_id: @appraisal.id,
           appraisal_participator_id: @appraisal_participator1.id,
           assessor_id: @user5.id)
    assess_relationship_params = {
        assess_type: 'superior_assess',
        assessor_id: @user5.id
    }
    assert_difference('AssessRelationship.count', -1) do
      delete destroy_assessor_appraisal_appraisal_participator_url(@appraisal.id, @appraisal_participator1.id), params: assess_relationship_params
    end
    assert_response :success
  end

end
