require 'test_helper'

class MedicalTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template1 = create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    @template2 = create(:medical_template, id: 2, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/01/01')
    @template3 = create(:medical_template, id: 3, chinese_name: '第五級醫療保險計劃', english_name: 'The fifth level medical insurance plan', simple_chinese_name: '第五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)

    @item_template1 = create(:medical_item_template, id: 1, chinese_name: '住院膳食', english_name: 'Hospital meal', simple_chinese_name: '住院膳食', can_be_delete: false)
    @item_template2 = create(:medical_item_template, id: 2, chinese_name: '醫生巡房', english_name: 'The doctor walk', simple_chinese_name: '医生巡房', can_be_delete: false)
    @item_template3 = create(:medical_item_template, id: 3, chinese_name: '住院服務', english_name: 'The hospital service', simple_chinese_name: '住院服务', can_be_delete: false)
    @item_template4 = create(:medical_item_template, id: 4, chinese_name: '專科醫療費', english_name: 'Specialized medical treatment', simple_chinese_name: '专科医疗费', can_be_delete: false)
    @item_template5 = create(:medical_item_template, id: 5, chinese_name: '中醫或跌打', english_name: 'Raditional Chinese medicine', simple_chinese_name: '中医或跌打', can_be_delete: false)
    @item_template6 = create(:medical_item_template, id: 6, chinese_name: '麻醉師費', english_name: 'Anesthetist fee', simple_chinese_name: '麻醉师费', can_be_delete: false)

    @item1 = create(:medical_item, id: 1, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 1)
    @item2 = create(:medical_item, id: 2, reimbursement_times: 10, reimbursement_amount_limit: 200, reimbursement_amount: 160, medical_item_template_id: 2, medical_template_id: 1)
    @item3 = create(:medical_item, id: 3, reimbursement_times: 10, reimbursement_amount_limit: 300, reimbursement_amount: 300, medical_item_template_id: 3, medical_template_id: 2)
    @item4 = create(:medical_item, id: 4, reimbursement_times: 10, reimbursement_amount_limit: 500, reimbursement_amount: 0, medical_item_template_id: 4, medical_template_id: 2)
    @item5 = create(:medical_item, id: 5, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 5, medical_template_id: 3)
    @item6 = create(:medical_item, id: 6, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 6, medical_template_id: 3)

    @template1.medical_items<<[@item1,@item2,@item3]
    @template2.medical_items<<[@item4,@item5]
    @template3.medical_items<<[@item6]

    MedicalTemplateSetting.load_predefined
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :medical_template_setting, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    get medical_templates_url
    assert_response :success
    response_record = json_res['data']
    assert_equal 3, response_record.count
    assert_equal 1, response_record.first['id']
    assert_equal 2, response_record.second['id']
    assert_equal 3, response_record.first['medical_items'].count
    assert_equal 2, response_record.second['medical_items'].count
    assert_not_nil response_record.first['medical_items'].first['medical_item_template']
  end

  test "should create" do
    # 不重名
    create_params = {
        chinese_name: '第三級醫療保險計劃',
        english_name: 'The third level medical insurance plan',
        simple_chinese_name: '第三级医疗保险计划',
        insurance_type: 'medical_template.enum_insurance_type.commercial_insurance',
        balance_date: '2017/12/01',
        medical_items: [
            {reimbursement_times: 6, reimbursement_amount_limit: 66, reimbursement_amount: 666, medical_item_template_id: 1},
            {reimbursement_times: 7, reimbursement_amount_limit: 77, reimbursement_amount: 777, medical_item_template_id: 2},
            {reimbursement_times: 8, reimbursement_amount_limit: 88, reimbursement_amount: 888, medical_item_template_id: 3}
        ],
    }
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    post medical_templates_url, params: { medical_template:  create_params }, as: :json
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    post medical_templates_url, params: { medical_template:  create_params }, as: :json
    assert_response :success
    assert_equal '第三級醫療保險計劃', MedicalTemplate.find(json_res['data']['id']).chinese_name
    assert_equal 'commercial_insurance', MedicalTemplate.find(json_res['data']['id']).insurance_type
    assert_equal 3, MedicalTemplate.find(json_res['data']['id']).medical_items.count
    assert_equal true, MedicalTemplate.find(json_res['data']['id']).can_be_delete
    assert_equal false, MedicalTemplate.find(json_res['data']['id']).undestroyable_forever
    assert_equal false, MedicalTemplate.find(json_res['data']['id']).undestroyable_temporarily

    # 重名
    create_params = {
        chinese_name: '第一級醫療保險計劃',
        english_name: 'The first level medical insurance plan',
        simple_chinese_name: '第一级医疗保险计划',
        insurance_type: 'medical_template.enum_insurance_type.commercial_insurance',
        balance_date: '2017/12/01',
        medical_items: [
            {reimbursement_times: 6, reimbursement_amount_limit: 66, reimbursement_amount: 666, medical_item_template_id: 1},
            {reimbursement_times: 7, reimbursement_amount_limit: 77, reimbursement_amount: 777, medical_item_template_id: 2},
            {reimbursement_times: 8, reimbursement_amount_limit: 88, reimbursement_amount: 888, medical_item_template_id: 3}
        ],
    }
    post medical_templates_url, params: { medical_template:  create_params }, as: :json
    assert_response :success
    assert_equal [], json_res['data']
  end

  test "should show" do
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get medical_template_url(@template1.id)
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get medical_template_url(@template1.id)
    assert_response :success
    assert_equal 3, json_res['data']['medical_items'].count
    json_res['data']['medical_items'].each do |record|
      assert_not_nil record['medical_item_template']
    end
  end

  test "should update 1.0" do
    # 改名字，全不重名
    update_params = {
        chinese_name: '第四級醫療保險計劃',
        english_name: 'The fourth level medical insurance plan',
        simple_chinese_name: '第四级医疗保险计划',
        insurance_type: 'medical_template.enum_insurance_type.commercial_insurance',
        balance_date: '2017/01/01',
        medical_items: [
            {reimbursement_times: 9, reimbursement_amount_limit: 99, reimbursement_amount: 999, medical_item_template_id: 4}
        ],
    }
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response :success
    assert_equal '第四級醫療保險計劃', MedicalTemplate.find(@template2.id).chinese_name
    assert_equal 'The fourth level medical insurance plan', MedicalTemplate.find(@template2.id).english_name
    assert_equal '第四级医疗保险计划', MedicalTemplate.find(@template2.id).simple_chinese_name
    assert_equal 'commercial_insurance', MedicalTemplate.find(@template2.id).insurance_type
    assert_equal '2017/01/01', MedicalTemplate.find(@template2.id).balance_date.strftime('%Y/%m/%d')
    assert_equal 1, MedicalTemplate.find(@template2.id).medical_items.count
  end

  test "should update 2.0" do
    # 改英文、简体中文名字
    update_params = {
        chinese_name: '第二級醫療保險計劃',
        english_name: 'The fourth level medical insurance plan', # 该名字未被占用
        simple_chinese_name: '第四级医疗保险计划', # 该名字未被占用
        insurance_type: 'medical_template.enum_insurance_type.commercial_insurance',
        balance_date: '2017/01/01',
        medical_items: [
            {reimbursement_times: 9, reimbursement_amount_limit: 99, reimbursement_amount: 999, medical_item_template_id: 4}
        ],
    }
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response :success
    assert_equal '第二級醫療保險計劃', MedicalTemplate.find(@template2.id).chinese_name
    assert_equal 'The fourth level medical insurance plan', MedicalTemplate.find(@template2.id).english_name
    assert_equal '第四级医疗保险计划', MedicalTemplate.find(@template2.id).simple_chinese_name
    assert_equal 'commercial_insurance', MedicalTemplate.find(@template2.id).insurance_type
    assert_equal '2017/01/01', MedicalTemplate.find(@template2.id).balance_date.strftime('%Y/%m/%d')
    assert_equal 1, MedicalTemplate.find(@template2.id).medical_items.count
  end

  test "should update 3.0" do
    # 改英文、简体中文名字
    update_params = {
        chinese_name: '第二級醫療保險計劃',
        english_name: 'The fourth level medical insurance plan', # 该名字未被占用
        simple_chinese_name: '第一级医疗保险计划', # 该名字已被占用
        insurance_type: 'medical_template.enum_insurance_type.commercial_insurance',
        balance_date: '2017/01/01',
        medical_items: [
            {reimbursement_times: 9, reimbursement_amount_limit: 99, reimbursement_amount: 999, medical_item_template_id: 4}
        ],
    }
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response :success
    assert_equal [], json_res['data']
  end

  test "should update 4.0" do
    # 不改名字，只改 medical_items，insurance_type，balance_date
    update_params = {
        chinese_name: '第二級醫療保險計劃',
        english_name: 'The second level medical insurance plan',
        simple_chinese_name: '第二级医疗保险计划',
        insurance_type: 'medical_template.enum_insurance_type.suncity_insurance',
        balance_date: '3000/01/01',
        medical_items: [
            {reimbursement_times: 12345, reimbursement_amount_limit: 12345, reimbursement_amount: 12345, medical_item_template_id: 4}
        ],
    }

    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_template_url(@template2.id), params: { medical_template:  update_params }, as: :json
    assert_response :success
    assert_equal '第二級醫療保險計劃', MedicalTemplate.find(@template2.id).chinese_name
    assert_equal 'The second level medical insurance plan', MedicalTemplate.find(@template2.id).english_name
    assert_equal '第二级医疗保险计划', MedicalTemplate.find(@template2.id).simple_chinese_name
    assert_equal 'suncity_insurance', MedicalTemplate.find(@template2.id).insurance_type
    assert_equal '3000/01/01', MedicalTemplate.find(@template2.id).balance_date.strftime('%Y/%m/%d')
    assert_equal 1, MedicalTemplate.find(@template2.id).medical_items.count
  end

  test "should destroy" do
    assert_difference('MedicalTemplate.count', -1) do
      MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
      delete medical_template_url(@template1.id)
      assert_response 403
      MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
      delete medical_template_url(@template1.id)
    end
    assert_response :success
  end

  test "should get create permission" do
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get create_permission_medical_templates_url, params: { medical_template: {
      chinese_name: '第三級醫療保險計劃',
      english_name: 'The third level medical insurance plan',
      simple_chinese_name: '第三级医疗保险计划',
    } }
    assert_response 403
    MedicalTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get create_permission_medical_templates_url, params: { medical_template: {
                                                               chinese_name: '第三級醫療保險計劃',
                                                               english_name: 'The third level medical insurance plan',
                                                               simple_chinese_name: '第三级医疗保险计划',
                                                           } }
    assert_response :success
    assert_equal true, json_res['data']
    get create_permission_medical_templates_url, params: { medical_template: {
                                                               chinese_name: '第一級醫療保險計劃',
                                                               english_name: 'The first level medical insurance plan',
                                                               simple_chinese_name: '第一级医疗保险计划',
                                                           } }
    assert_response :success
    assert_equal false, json_res['data']

    get create_permission_medical_templates_url, params: { medical_template: {
                                                               chinese_name: '第四級醫療保險計劃',
                                                               english_name: 'The fourth level medical insurance plan',
                                                               simple_chinese_name: '第四级医疗保险计划',
                                                           } }
    assert_response :success
    assert_equal true, json_res['data']

    get create_permission_medical_templates_url, params: { medical_template: {
                                                               chinese_name: '第二級醫療保險計劃',
                                                               english_name: 'The fourth level medical insurance plan',
                                                               simple_chinese_name: '第四级医疗保险计划',
                                                           } }
    assert_response :success
    assert_equal false, json_res['data']
  end

end
