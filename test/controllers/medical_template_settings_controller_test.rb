require 'test_helper'

class MedicalTemplateSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 已生效
    @template1 = create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template2 = create(:medical_template, id: 2, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template3 = create(:medical_template, id: 3, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template4 = create(:medical_template, id: 4, chinese_name: '第四級醫療保險計劃', english_name: 'The fourth level medical insurance plan', simple_chinese_name: '第四级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template5 = create(:medical_template, id: 5, chinese_name: '第五級醫療保險計劃', english_name: 'The fifth level medical insurance plan', simple_chinese_name: '第五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30', can_be_delete: true)

    # 未生效
    @template6 = create(:medical_template, id: 6, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template7 = create(:medical_template, id: 7, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template8 = create(:medical_template, id: 8, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30', can_be_delete: true)
    @template9 = create(:medical_template, id: 9, chinese_name: '第四、五級醫療保險計劃', english_name: 'The fourth/fifth level medical insurance plan', simple_chinese_name: '第四、五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30', can_be_delete: true)

    MedicalTemplateSetting.load_predefined
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :medical_template_setting, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should show" do
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    get '/medical_template_settings'
    assert_response 403
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    get '/medical_template_settings'
    assert_response :success
  end

  test "should update" do
    update_params = {
        sections: [
            { employee_grade: 1, current_template_id: 1, impending_template_id: '6', effective_date: (Date.today-3.month).to_s.gsub('-','/') },
            { employee_grade: 2, current_template_id: 2, impending_template_id: '', effective_date: nil },
            { employee_grade: 3, current_template_id: '3', impending_template_id: nil, effective_date: '' },
            { employee_grade: 4, current_template_id: '4', impending_template_id: 9, effective_date: (Date.today+3.year).to_s.gsub('-','/') },
            { employee_grade: 5, current_template_id: 2, impending_template_id: 9, effective_date: (Date.today+6.month).to_s.gsub('-','/') },
        ]
    }
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_template_settings_url, params: {medical_template_setting: update_params}, as: :json
    assert_response 403
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_template_settings_url, params: {medical_template_setting: update_params}, as: :json
    assert_response :success
    MedicalTemplateSetting.first[:sections].each do |record|
      if record['current_template_id'].is_a?(Integer) || (record['current_template_id'].is_a?(String)&&record['current_template_id'].length>0)
        assert_equal false, MedicalTemplate.find(record['current_template_id'].to_i).can_be_delete
        assert_equal true, MedicalTemplate.find(record['current_template_id'].to_i).undestroyable_forever
        assert_equal true, MedicalTemplate.find(record['current_template_id'].to_i).undestroyable_temporarily
      end
      if record['impending_template_id'].is_a?(Integer) || (record['impending_template_id'].is_a?(String)&&record['impending_template_id'].length>0)
        # assert_equal false, MedicalTemplate.find(record['impending_template_id'].to_i).can_be_delete
        # assert_equal false, MedicalTemplate.find(record['impending_template_id'].to_i).undestroyable_forever
        assert_equal true, MedicalTemplate.find(record['impending_template_id'].to_i).undestroyable_temporarily
      end
    end

    assert_equal MedicalTemplate.find(8).can_be_delete, true
    assert_equal MedicalTemplate.find(9).can_be_delete, false

    update_params = {
      sections: [
        { employee_grade: 1, current_template_id: 6, impending_template_id: nil, effective_date: nil },
        { employee_grade: 2, current_template_id: 2, impending_template_id: nil, effective_date: nil },
        { employee_grade: 3, current_template_id: 3, impending_template_id: nil, effective_date: '' },
        { employee_grade: 4, current_template_id: 4, impending_template_id: 8, effective_date: (Date.today+3.year).to_s.gsub('-','/') },
        { employee_grade: 5, current_template_id: 2, impending_template_id: 8, effective_date: (Date.today+6.month).to_s.gsub('-','/') },
      ]
    }
    patch medical_template_settings_url, params: {medical_template_setting: update_params}, as: :json
    assert_response :success

    assert_equal MedicalTemplate.find(9).can_be_delete, true

    get medical_templates_url
    assert_response :success
    assert_equal json_res['data'][1]['user_grades'], [2,5]

    # MedicalTemplateSetting.auto_take_effect
  end

  test 'should_auto_update' do
    medical_template_setting = MedicalTemplateSetting.first
    update_params = {
      sections: [
        { employee_grade: 1, current_template_id: 1, impending_template_id: 6, effective_date: Time.zone.parse('2016/01/01') },
        { employee_grade: 2, current_template_id: 2, impending_template_id: nil, effective_date: nil },
        { employee_grade: 3, current_template_id: 3, impending_template_id: nil, effective_date: nil },
        { employee_grade: 4, current_template_id: 4, impending_template_id: 9, effective_date: Time.zone.parse('2017/12/01') },
        { employee_grade: 5, current_template_id: 2, impending_template_id: 9, effective_date: Time.zone.parse('2019/01/01') },
      ]
    }
    medical_template_setting.update(update_params)
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@another_user)
    get '/medical_template_settings'
    assert_response 403
    MedicalTemplateSettingsController.any_instance.stubs(:current_user).returns(@current_user)
    get '/medical_template_settings'
    assert_response :success

    assert_equal medical_template_setting.sections[0]['impending_template_id'], 6
    assert_equal medical_template_setting.sections[1]['impending_template_id'], nil
    assert_equal medical_template_setting.sections[2]['impending_template_id'], nil
    assert_equal medical_template_setting.sections[3]['impending_template_id'], 9
    assert_equal medical_template_setting.sections[4]['impending_template_id'], 9
    MedicalTemplateSetting.auto_update
    medical_template_setting = MedicalTemplateSetting.first
    assert_equal medical_template_setting.sections[0]['impending_template_id'], nil
    assert_equal medical_template_setting.sections[1]['impending_template_id'], nil
    assert_equal medical_template_setting.sections[2]['impending_template_id'], nil
    assert_equal medical_template_setting.sections[3]['impending_template_id'], 9
    assert_equal medical_template_setting.sections[4]['impending_template_id'], 9

    assert_equal medical_template_setting.sections[0]['current_template_id'], 6
    assert_equal medical_template_setting.sections[1]['current_template_id'], 2
    assert_equal medical_template_setting.sections[2]['current_template_id'], 3
    assert_equal medical_template_setting.sections[3]['current_template_id'], 4
    assert_equal medical_template_setting.sections[4]['current_template_id'], 2

    assert_equal medical_template_setting.sections[0]['effective_date'], nil

  end

end
