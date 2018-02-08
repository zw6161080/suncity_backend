require 'test_helper'

class AppraisalEmployeeSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @appraisal_basic_setting = create(:appraisal_basic_setting)
    @location_a = create(:location, chinese_name: 'a场馆a')
    @location_b = create(:location, chinese_name: 'b场馆b')
    @location_c = create(:location, chinese_name: 'c场馆c')
    @department_a = create(:department, chinese_name: 'a部门a')
    @department_b = create(:department, chinese_name: 'b部门b')
    @department_c = create(:department, chinese_name: 'c部门c')
    @location_a.departments << @department_a
    @location_b.departments << @department_b
    @location_c.departments << @department_c
    @location_a.save!
    @location_b.save!
    @location_c.save!
    @position_a = create(:position)
    @position_b = create(:position)
    @position_c = create(:position)
    profile1 = create_profile
    profile2 = create_profile
    profile3 = create_profile

    @user_a = profile1.user
    @user_b = profile2.user
    @user_c = profile3.user

    @user_a.location = @location_a
    @user_b.location = @location_b
    @user_c.location = @location_c

    @user_a.department = @department_a
    @user_b.department = @department_b
    @user_c.department = @department_c

    @user_a.position = @position_a
    @user_b.position = @position_b
    @user_c.position = @position_c

    @user_a.grade = 3
    @user_b.grade = 3
    @user_c.grade = 3

    @user_a.save!
    @user_b.save!
    @user_c.save!

    @appraisal_department_setting = create(:appraisal_department_setting,
                                           appraisal_basic_setting_id: @appraisal_basic_setting.id,
                                           location_id: @location_a.id,
                                           department_id: @department_a.id)

    AppraisalBasicSetting.load_predefined
    AppraisalDepartmentSetting.create_all_related_settings
    AppraisalEmployeeSetting.generate

    @appraisal_group = create(:appraisal_group, name: 'test', appraisal_department_setting_id: @appraisal_department_setting.id)

    AppraisalEmployeeSettingsController.any_instance.stubs(:current_user).returns(create_test_user)
    AppraisalEmployeeSettingsController.any_instance.stubs(:authorize).returns(true)

  end

  test "should query_index" do

    params = { grade: 3, location: [@location_a.id, @location_b.id], employee_id: @user_a.empoid }
    get appraisal_employee_settings_url, params: params
    assert_response :success

    data = json_res['data']
    meta = json_res['meta']
    assert_equal data.count, 2
    assert_equal meta['current_page'], 1
    assert_equal meta['total_count'], 2

    params = { grade: 3, location: [@location_a.id, @location_b.id] }
    get appraisal_employee_settings_url, params: params
    assert_response :success

    data = json_res['data']
    meta = json_res['meta']
    assert_equal data.count, 2
    assert_equal meta['current_page'], 1
    assert_equal meta['total_count'], 2

    params = { grade: 3 }
    get appraisal_employee_settings_url, params: params
    assert_response :success

    data = json_res['data']
    meta = json_res['meta']
    assert_equal data.count, 3
    assert_equal meta['current_page'], 1
    assert_equal meta['total_count'], 3
  end

  test "should update" do
    update_params = {
      appraisal_group_id: @appraisal_group.id,
      level_in_department: 3
    }
    patch appraisal_employee_setting_url(AppraisalEmployeeSetting.first.id), params: update_params
    assert_response :success
    assert_equal AppraisalEmployeeSetting.first.appraisal_group_id, @appraisal_group.id
    assert_equal AppraisalEmployeeSetting.first.level_in_department, 3
    assert_equal AppraisalEmployeeSetting.first.has_finished, true
    update_params = {
      level_in_department: 4
    }
    patch appraisal_employee_setting_url(AppraisalEmployeeSetting.first.id), params: update_params
    assert_response :success
    assert_equal AppraisalEmployeeSetting.first.appraisal_group_id, @appraisal_group.id
    assert_equal AppraisalEmployeeSetting.first.level_in_department, 4
    assert_equal AppraisalEmployeeSetting.first.has_finished, true
    update_params = {
        level_in_department: 4
    }
    patch appraisal_employee_setting_url(AppraisalEmployeeSetting.first.id), params: update_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
  end
end
