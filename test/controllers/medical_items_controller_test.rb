require 'test_helper'

class MedicalItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item_template1 = create(:medical_item_template, id: 1, chinese_name: '住院膳食', english_name: 'Hospital meal', simple_chinese_name: '住院膳食', can_be_delete: false)
    @item_template2 = create(:medical_item_template, id: 2, chinese_name: '醫生巡房', english_name: 'The doctor walk', simple_chinese_name: '医生巡房', can_be_delete: false)
    @item_template3 = create(:medical_item_template, id: 3, chinese_name: '住院服務', english_name: 'The hospital service', simple_chinese_name: '住院服务', can_be_delete: false)
    @item_template4 = create(:medical_item_template, id: 4, chinese_name: '專科醫療費', english_name: 'Specialized medical treatment', simple_chinese_name: '专科医疗费', can_be_delete: false)
    @item_template5 = create(:medical_item_template, id: 5, chinese_name: '中醫或跌打', english_name: 'Raditional Chinese medicine', simple_chinese_name: '中医或跌打', can_be_delete: false)
    @item_template6 = create(:medical_item_template, id: 6, chinese_name: '麻醉師費', english_name: 'Anesthetist fee', simple_chinese_name: '麻醉师费', can_be_delete: false)

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

  test "should index" do
    MedicalItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get medical_items_url, params: {medical_template_id: 1}
    assert_response 403
    MedicalItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get medical_items_url, params: {medical_template_id: 1}
    assert_response :success
  end

  test "should create medical_item" do
    MedicalItemsController.any_instance.stubs(:current_user).returns(@another_user)
    post medical_items_url, params: { medical_item: {
      reimbursement_times: 6,
      reimbursement_amount_limit: 66,
      reimbursement_amount: 666,
      medical_item_template_id: 1,
      medical_template_id: 1 } }, as: :json
    assert_response 403
    MedicalItemsController.any_instance.stubs(:current_user).returns(@current_user)
    post medical_items_url, params: { medical_item: {
        reimbursement_times: 6,
        reimbursement_amount_limit: 66,
        reimbursement_amount: 666,
        medical_item_template_id: 1,
        medical_template_id: 1 } }, as: :json
    assert_response :success
    assert_equal 6, MedicalItem.last.reimbursement_times
    assert_equal 66, MedicalItem.last.reimbursement_amount_limit
    assert_equal 666, MedicalItem.last.reimbursement_amount
    assert_equal 1, MedicalItem.last.medical_item_template_id
    assert_equal 1, MedicalItem.last.medical_template_id
  end

  test "should destroy medical_item" do
    assert_difference('MedicalItem.count', -1) do
      MedicalItemsController.any_instance.stubs(:current_user).returns(@another_user)
      delete medical_item_url(@item6.id)
      assert_response 403
      MedicalItemsController.any_instance.stubs(:current_user).returns(@current_user)
      delete medical_item_url(@item6.id)
    end
    assert_response :success
  end

end
