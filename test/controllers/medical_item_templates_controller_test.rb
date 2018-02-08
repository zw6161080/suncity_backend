require 'test_helper'

class MedicalItemTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_template1 = create(:medical_item_template, id: 1, chinese_name: '住院膳食', english_name: 'Hospital meal', simple_chinese_name: '住院膳食', can_be_delete: false)
    @item_template2 = create(:medical_item_template, id: 2, chinese_name: '醫生巡房', english_name: 'The doctor walk', simple_chinese_name: '医生巡房', can_be_delete: false)
    @item_template3 = create(:medical_item_template, id: 3, chinese_name: '住院服務', english_name: 'The hospital service', simple_chinese_name: '住院服务', can_be_delete: false)
    @item_template4 = create(:medical_item_template, id: 4, chinese_name: '專科醫療費', english_name: 'Specialized medical treatment', simple_chinese_name: '专科医疗费', can_be_delete: false)
    @item_template5 = create(:medical_item_template, id: 5, chinese_name: '中醫或跌打', english_name: 'Raditional Chinese medicine', simple_chinese_name: '中医或跌打', can_be_delete: false)
    @item_template6 = create(:medical_item_template, id: 6, chinese_name: '麻醉師費', english_name: 'Anesthetist fee', simple_chinese_name: '麻醉师费', can_be_delete: false)
    @item_template7 = create(:medical_item_template, id: 7, chinese_name: 'xxx', english_name: 'xxx', simple_chinese_name: 'xxx', can_be_delete: true)
    @item_template8 = create(:medical_item_template, id: 8, chinese_name: 'xxx', english_name: 'xxx', simple_chinese_name: 'xxx', can_be_delete: true)

    @template1 = create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    @template2 = create(:medical_template, id: 2, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today+2.month)
    @template3 = create(:medical_template, id: 3, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)

    @item1 = create(:medical_item, id: 1, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 1)
    @item2 = create(:medical_item, id: 2, reimbursement_times: 10, reimbursement_amount_limit: 200, reimbursement_amount: 160, medical_item_template_id: 2, medical_template_id: 1)
    @item3 = create(:medical_item, id: 3, reimbursement_times: 10, reimbursement_amount_limit: 300, reimbursement_amount: 300, medical_item_template_id: 3, medical_template_id: 2)
    @item4 = create(:medical_item, id: 4, reimbursement_times: 10, reimbursement_amount_limit: 500, reimbursement_amount: 0, medical_item_template_id: 4, medical_template_id: 2)
    @item5 = create(:medical_item, id: 5, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 5, medical_template_id: 3)
    @item6 = create(:medical_item, id: 6, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 6, medical_template_id: 3)
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :medical_template_setting, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    MedicalItemTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get medical_item_templates_url
    assert_response 403
    MedicalItemTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get medical_item_templates_url
    assert_response :success
    response_record = json_res['data']
    assert_equal 8, response_record.count
    response_record.each do |record|
      assert_not_nil record['chinese_name']
      assert_not_nil record['english_name']
      assert_not_nil record['simple_chinese_name']
    end
  end

  test "should create" do
    MedicalItemTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    post medical_item_templates_url, params: { medical_item_template: {
      templates: [
        { chinese_name: '外科手術費', english_name: 'Surgical fee', simple_chinese_name: '外科手术费' },
        { chinese_name: '西醫門診', english_name: 'Western medicine', simple_chinese_name: '西医门诊' }
      ],
      delete_ids: [@item_template7.id, @item_template8.id]
    } }, as: :json
    assert_response 403
    MedicalItemTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    post medical_item_templates_url, params: { medical_item_template: {
        templates: [
            { chinese_name: '外科手術費', english_name: 'Surgical fee', simple_chinese_name: '外科手术费' },
            { chinese_name: '西醫門診', english_name: 'Western medicine', simple_chinese_name: '西医门诊' }
        ],
        delete_ids: [@item_template7.id, @item_template8.id]
    } }, as: :json
    assert_response :success
    assert_equal 8, MedicalItemTemplate.count
    MedicalItemTemplate.last(2).each do |record|
      assert_equal true, record['can_be_delete']
      assert ['外科手術費','西醫門診'].include?(record['chinese_name'])
      assert ['Surgical fee','Western medicine'].include?(record['english_name'])
      assert ['外科手术费','西医门诊'].include?(record['simple_chinese_name'])
    end
  end

end
