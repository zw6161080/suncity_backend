require 'test_helper'

class AppraisalGroupsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @location = create(:location)
    @department = create(:department)
    @appraisal_department_setting = create(:appraisal_department_setting,
                                           location_id: @location.id,
                                           department_id: @department.id
    )

    AppraisalBasicSetting.load_predefined
    AppraisalDepartmentSetting.create_all_related_settings
  end

  test "should create" do
    create_params = {
      appraisal_department_setting_id: @appraisal_department_setting.id,
      name: 'test'
    }
    assert_difference('AppraisalGroup.count', 1) do
      post appraisal_department_setting_appraisal_groups_url(appraisal_department_setting_id: @appraisal_department_setting.id), params: create_params
    end
    assert_response :success
    assert_equal @appraisal_department_setting.appraisal_groups.count, 1
    assert_equal @appraisal_department_setting.appraisal_groups.first.name, 'test'
  end

  test "should_update" do
    create_params = {
      appraisal_department_setting_id: @appraisal_department_setting.id,
      name: 'test'
    }
    assert_difference('AppraisalGroup.count', 1) do
      post appraisal_department_setting_appraisal_groups_url(
             appraisal_department_setting_id: @appraisal_department_setting.id
           ), params: create_params
    end
    assert_response :success
    assert_equal @appraisal_department_setting.appraisal_groups.count, 1

    update_params = {
      name: 'test2'
    }
    appraisal_group = json_res['appraisal_group']
    patch appraisal_department_setting_appraisal_group_url(
            appraisal_department_setting_id: @appraisal_department_setting.id,
            id: appraisal_group['id']
          ), params: update_params

    assert_response :success
    assert_equal @appraisal_department_setting.appraisal_groups.count, 1
    assert_equal @appraisal_department_setting.appraisal_groups.first.name, 'test2'
  end

  test "should destroy" do
    create_params = {
      appraisal_department_setting_id: @appraisal_department_setting.id,
      name: 'test'
    }
    assert_difference('AppraisalGroup.count', 1) do
      post appraisal_department_setting_appraisal_groups_url(
               appraisal_department_setting_id: @appraisal_department_setting.id
             ), params: create_params
    end
    assert_response :success
    assert_equal @appraisal_department_setting.appraisal_groups.count, 1

    appraisal_group = json_res['appraisal_group']
    assert_difference('AppraisalGroup.count', -1) do
      delete appraisal_department_setting_appraisal_group_url(
             appraisal_department_setting_id: @appraisal_department_setting.id,
             id: appraisal_group['id']
           )
    end
    assert_response :success
    assert_equal @appraisal_department_setting.appraisal_groups.count, 0
  end
end
