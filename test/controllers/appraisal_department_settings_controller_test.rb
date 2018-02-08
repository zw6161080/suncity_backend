require 'test_helper'

class AppraisalDepartmentSettingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @location = create(:location)
    @department1 = create(:department)
    @department2 = create(:department)
    @department3 = create(:department)
    @department4 = create(:department)
    @department5 = create(:department)
    @questionnaire_template = create(:questionnaire_template, id: 2, template_type: '360_assessment')
    @another_questionnaire_template = create(:questionnaire_template)
    @another_location = create(:location)
    location_a = @location
    location_a.departments << @department1
    location_a.departments << @department2
    location_a.departments << @department3
    location_a.save
    location_b = @another_location
    location_b.departments << @department4
    location_b.departments << @department5
    location_b.save

    AppraisalBasicSetting.load_predefined
    AppraisalDepartmentSetting.create_all_related_settings
    AppraisalDepartmentSettingsController.any_instance.stubs(:current_user).returns(create_test_user)
    AppraisalDepartmentSettingsController.any_instance.stubs(:authorize).returns(true)
  end

  test "location with departments" do
    get location_with_departments_appraisal_department_settings_url
    assert_response :success
  end

  test "fields options" do
    get fields_options_appraisal_department_settings_url
    assert_response :success
    assert_equal json_res['appraisal_questionnaire_templates'].count, 1
  end

  test "update group situation" do
    group_params = {
      whether_group_inside: true,
      group_names: ['test1', 'test2']
    }
    appraisal_department_setting = AppraisalDepartmentSetting.find_by(location_id: @location.id, department_id: @department1.id)

    patch update_group_situation_appraisal_department_setting_url(appraisal_department_setting.id), params: group_params
    assert_response :success
    assert_equal json_res['appraisal_department_setting']['appraisal_groups'].count, 2

    group_params = {
      whether_group_inside: false,
      group_names: ['test1', 'test2']
    }
    patch update_group_situation_appraisal_department_setting_url(appraisal_department_setting.id), params: group_params
    assert_response :success
    assert_equal json_res['appraisal_department_setting']['appraisal_groups'].count, 0

    group_params = {
      whether_group_inside: true,
      group_names: ['test1', 'test2', 'test3']
    }
    patch update_group_situation_appraisal_department_setting_url(appraisal_department_setting.id), params: group_params
    assert_response :success
    assert_equal json_res['appraisal_department_setting']['appraisal_groups'].count, 3
  end

  test "should index" do
    get appraisal_department_settings_url
    assert_response :success
    assert_equal json_res['appraisal_department_settings'].count, 5
    json_res['appraisal_department_settings'].each do |record|
      assert_equal record['can_across_appraisal_grade'], false
      assert_equal record['appraisal_mode_superior'], 'assessed_by_all_superiors'
      assert_equal record['appraisal_mode_collegue'], 'whole_department'
      assert_equal record['appraisal_mode_subordinate'], 'all_superiors'
      assert_equal record['appraisal_grade_quantity_inside'], 3
      assert_equal record['whether_group_inside'], false
      assert_equal record['appraisal_groups'].count, 0
    end
  end

  test "should update" do
    appraisal_department_setting = AppraisalDepartmentSetting.find_by(location_id: @location.id, department_id: @department1.id)
    update_params = {
      can_across_appraisal_grade: true,
      appraisal_mode_superior: 'assessed_by_part_of_the_superiors',
      appraisal_times_superior: 3,
      appraisal_mode_collegue: 'group_only',
      appraisal_times_collegue: 4,
      appraisal_mode_subordinate: 'part_of_the_superiors',
      appraisal_times_subordinate: 5,
      appraisal_grade_quantity_inside: 5,
      whether_group_inside: true,
      group_A_appraisal_template_id: @questionnaire_template.id,
      group_B_appraisal_template_id: @questionnaire_template.id,
      group_C_appraisal_template_id: @questionnaire_template.id,
      group_D_appraisal_template_id: @questionnaire_template.id,
      group_E_appraisal_template_id: @questionnaire_template.id
    }

    patch appraisal_department_setting_url(appraisal_department_setting.id), params: update_params
    assert_response :success

    record = AppraisalDepartmentSetting.where(location_id: @location.id, department_id: @department1.id).first
    assert_equal record['appraisal_mode_superior'], 'assessed_by_part_of_the_superiors'
    assert_equal record['can_across_appraisal_grade'], true
    assert_equal record['appraisal_mode_collegue'], 'group_only'
    assert_equal record['appraisal_mode_subordinate'], 'part_of_the_superiors'
    assert_equal record['appraisal_times_superior'], 3
    assert_equal record['appraisal_times_collegue'], 4
    assert_equal record['appraisal_times_subordinate'], 5
    assert_equal record['appraisal_grade_quantity_inside'], 5
    assert_equal record['whether_group_inside'], false
  end

  test "should batch update" do
    batch_update_params = {
      location_ids: [ @location.id, @another_location.id],
      can_across_appraisal_grade: false,
      appraisal_mode_superior: 'assessed_by_part_of_the_superiors',
      appraisal_times_superior: 3,
      appraisal_mode_collegue: 'group_only',
      appraisal_times_collegue: 4,
      appraisal_mode_subordinate: 'part_of_the_superiors',
      appraisal_times_subordinate: 5,
      appraisal_grade_quantity_inside: 5,
      whether_group_inside: true,
      group_A_appraisal_template_id: @another_questionnaire_template.id,
      group_B_appraisal_template_id: @another_questionnaire_template.id,
      group_C_appraisal_template_id: @another_questionnaire_template.id,
      group_D_appraisal_template_id: @another_questionnaire_template.id,
      group_E_appraisal_template_id: @questionnaire_template.id,
    }
    patch batch_update_appraisal_department_settings_url, params: batch_update_params
    assert_response :ok

    json_res['appraisal_department_settings'].each do |r|
      assert_equal r['can_across_appraisal_grade'], false
      assert_equal r['appraisal_mode_superior'], 'assessed_by_part_of_the_superiors'
      assert_equal r['appraisal_times_superior'], 3
      assert_equal r['appraisal_mode_collegue'], 'group_only'
      assert_equal r['appraisal_times_collegue'], 4
      assert_equal r['appraisal_mode_subordinate'], 'part_of_the_superiors'
      assert_equal r['appraisal_times_subordinate'], 5
      assert_equal r['appraisal_grade_quantity_inside'], 5
      assert_equal r['whether_group_inside'], false
      assert_equal r['group_A_appraisal_template_id'], @another_questionnaire_template.id
      assert_equal r['group_B_appraisal_template_id'], @another_questionnaire_template.id
      assert_equal r['group_C_appraisal_template_id'], @another_questionnaire_template.id
      assert_equal r['group_D_appraisal_template_id'], @another_questionnaire_template.id
      assert_equal r['group_E_appraisal_template_id'], @questionnaire_template.id

      batch_update_params = {
          #location_ids: [ @location.id, @another_location.id],
      }
      patch batch_update_appraisal_department_settings_url, params: batch_update_params
      assert_response 422
      assert_equal json_res['data'][0]['message'], '參數不完整'
    end

  end

end
