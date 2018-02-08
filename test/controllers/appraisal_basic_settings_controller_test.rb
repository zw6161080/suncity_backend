require 'test_helper'

class AppraisalBasicSettingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    AppraisalBasicSetting.load_predefined
    AppraisalBasicSettingsController.any_instance.stubs(:current_user).returns(:create_test_user)
    AppraisalBasicSettingsController.any_instance.stubs(:authorize).returns(true)
  end

  test "should show" do
    get appraisal_basic_setting_url, as: :json
    assert_response :success
    data = json_res['data']
    assert_equal data['ratio_superior'], 25
    assert_equal data['ratio_subordinate'], 25
    assert_equal data['ratio_collegue'], 25
    assert_equal data['ratio_self'], 25
    assert_equal data['ratio_collegue'], 25
    assert_equal data['introduction'], nil
    assert_equal data['group_A'], [1, 2, 3, 4]
    assert_equal json_res['data']['appraisal_attachments'].count, 0
  end

  test "should update" do
    update_params = {
      ratio_superior: 50,
      ratio_subordinate: 50,
      ratio_collegue: 50,
      ratio_self: 50,
      ratio_others_superior: 100,
      ratio_others_subordinate: 100,
      ratio_others_collegue: 100,
      questionnaire_submit_once_only: true,
      introduction: 'babababababababa',
      group_A: [1],
      group_B: [2],
      group_C: [3],
      group_D: [4],
      group_E: [5],
    }

    patch appraisal_basic_setting_url, params: update_params, as: :json
    assert_response :success

    get appraisal_basic_setting_url, as: :json
    assert_response :success
    data = json_res['data']
    assert_equal data['ratio_superior'], 50
    assert_equal data['ratio_subordinate'], 50
    assert_equal data['ratio_collegue'], 50
    assert_equal data['ratio_self'], 50
    assert_equal data['ratio_collegue'], 50
    assert_equal data['introduction'], 'babababababababa'
    assert_equal data['group_A'], [1]
  end

end
