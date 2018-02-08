require 'test_helper'

class MedicalReimbursementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 已生效
    @template1 = create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30')
    @template2 = create(:medical_template, id: 2, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30')
    @template3 = create(:medical_template, id: 3, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30')
    @template4 = create(:medical_template, id: 4, chinese_name: '第四級醫療保險計劃', english_name: 'The fourth level medical insurance plan', simple_chinese_name: '第四级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30')
    @template5 = create(:medical_template, id: 5, chinese_name: '第五級醫療保險計劃', english_name: 'The fifth level medical insurance plan', simple_chinese_name: '第五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30')

    # 未生效
    @template6 = create(:medical_template, id: 6, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30')
    @template7 = create(:medical_template, id: 7, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: '2017/09/30')
    @template8 = create(:medical_template, id: 8, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30')
    @template9 = create(:medical_template, id: 9, chinese_name: '第四、五級醫療保險計劃', english_name: 'The fourth/fifth level medical insurance plan', simple_chinese_name: '第四、五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: '2017/09/30')

    @item_template1 = create(:medical_item_template, id: 1, chinese_name: '住院膳食', english_name: 'Hospital meal', simple_chinese_name: '住院膳食', can_be_delete: false)
    @item_template2 = create(:medical_item_template, id: 2, chinese_name: '醫生巡房', english_name: 'The doctor walk', simple_chinese_name: '医生巡房', can_be_delete: false)
    @item_template3 = create(:medical_item_template, id: 3, chinese_name: '住院服務', english_name: 'The hospital service', simple_chinese_name: '住院服务', can_be_delete: false)
    @item_template4 = create(:medical_item_template, id: 4, chinese_name: '專科醫療費', english_name: 'Specialized medical treatment', simple_chinese_name: '专科医疗费', can_be_delete: false)
    @item_template5 = create(:medical_item_template, id: 5, chinese_name: '中醫或跌打', english_name: 'Raditional Chinese medicine', simple_chinese_name: '中医或跌打', can_be_delete: false)
    @item_template6 = create(:medical_item_template, id: 6, chinese_name: '麻醉師費', english_name: 'Anesthetist fee', simple_chinese_name: '麻醉师费', can_be_delete: false)
    @item_template7 = create(:medical_item_template, id: 7, chinese_name: '意外醫療', english_name: 'Accident medical treatment', simple_chinese_name: '意外医疗费', can_be_delete: false)
    @item_template8 = create(:medical_item_template, id: 8, chinese_name: 'X光檢驗及化驗費用', english_name: 'X-ray inspection and test fee', simple_chinese_name: 'X光检验及化验费用', can_be_delete: false)
    @item_template9 = create(:medical_item_template, id: 9, chinese_name: '緊急援助', english_name: 'Emergency aid', simple_chinese_name: '紧急援助', can_be_delete: false)

    @item1 = create(:medical_item, id: 1, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 1)
    @item2 = create(:medical_item, id: 2, reimbursement_times: 10, reimbursement_amount_limit: 200, reimbursement_amount: 160, medical_item_template_id: 2, medical_template_id: 1)
    @item3 = create(:medical_item, id: 3, reimbursement_times: 10, reimbursement_amount_limit: 300, reimbursement_amount: 300, medical_item_template_id: 3, medical_template_id: 2)
    @item4 = create(:medical_item, id: 4, reimbursement_times: 10, reimbursement_amount_limit: 500, reimbursement_amount: 0, medical_item_template_id: 4, medical_template_id: 2)
    @item5 = create(:medical_item, id: 5, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 5, medical_template_id: 2)
    @item6 = create(:medical_item, id: 6, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 6, medical_template_id: 2)
    @item7 = create(:medical_item, id: 7, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 7, medical_template_id: 3)
    @item8 = create(:medical_item, id: 8, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 8, medical_template_id: 3)
    @item9 = create(:medical_item, id: 9, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 9, medical_template_id: 3)
    @item10 = create(:medical_item, id: 10, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 4)
    @item11 = create(:medical_item, id: 11, reimbursement_times: 10, reimbursement_amount_limit: 200, reimbursement_amount: 160, medical_item_template_id: 2, medical_template_id: 4)
    @item12 = create(:medical_item, id: 12, reimbursement_times: 10, reimbursement_amount_limit: 300, reimbursement_amount: 300, medical_item_template_id: 3, medical_template_id: 5)

    @item13 = create(:medical_item, id: 13, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 6)
    @item14 = create(:medical_item, id: 14, reimbursement_times: 10, reimbursement_amount_limit: 200, reimbursement_amount: 160, medical_item_template_id: 2, medical_template_id: 6)
    @item15 = create(:medical_item, id: 15, reimbursement_times: 10, reimbursement_amount_limit: 300, reimbursement_amount: 300, medical_item_template_id: 3, medical_template_id: 6)
    @item16 = create(:medical_item, id: 16, reimbursement_times: 10, reimbursement_amount_limit: 500, reimbursement_amount: 0, medical_item_template_id: 4, medical_template_id: 6)
    @item17 = create(:medical_item, id: 17, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 5, medical_template_id: 7)
    @item18 = create(:medical_item, id: 18, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 6, medical_template_id: 7)
    @item19 = create(:medical_item, id: 19, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 7, medical_template_id: 7)
    @item20 = create(:medical_item, id: 20, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 8, medical_template_id: 8)
    @item21 = create(:medical_item, id: 21, reimbursement_times: 10, reimbursement_amount_limit: 100, reimbursement_amount: 80, medical_item_template_id: 9, medical_template_id: 8)
    @item22 = create(:medical_item, id: 22, reimbursement_times: 10, reimbursement_amount_limit: 150, reimbursement_amount: 120, medical_item_template_id: 1, medical_template_id: 9)

    @template1.medical_items<<[@item1,@item2]
    @template2.medical_items<<[@item3,@item4,@item5,@item6]
    @template3.medical_items<<[@item7,@item8,@item9]
    @template4.medical_items<<[@item10,@item11]
    @template5.medical_items<<[@item12]

    @template6.medical_items<<[@item13,@item14,@item15,@item16]
    @template7.medical_items<<[@item17,@item18,@item19]
    @template8.medical_items<<[@item20,@item21]
    @template9.medical_items<<[@item22]

    create(:department, id: 9,   chinese_name: '行政及人力資源部')
    create(:position,   id: 39,  chinese_name: '網絡及系統副總監')

    create(:user, id: 100, grade: 1, department_id: 9, position_id: 39, chinese_name: '山姆', english_name: 'Sam')
    create(:user, id: 101, grade: 2, department_id: 9, position_id: 39, chinese_name: '莉莉', english_name: 'Lily')
    create(:user, id: 102, grade: 3, department_id: 9, position_id: 39, chinese_name: '阿汤哥', english_name: 'Tom')
    create(:user, id: 103, grade: 4, department_id: 9, position_id: 39, chinese_name: '杰克船长', english_name: 'Captain Jack')
    create(:user, id: 104, grade: 5, department_id: 9, position_id: 39, chinese_name: '小辣椒', english_name: 'Spicy')

    create(:attachment, id: 1)
    create(:attachment, id: 2)
    create(:attachment_item, id: 20170201, creator_id: 102, attachment_id: 1 )
    create(:attachment_item, id: 20170202, creator_id: 102, attachment_id: 2 )
    create(:attachment_item, id: 20170203, creator_id: 102 )
    create(:attachment_item, id: 20170204, creator_id: 102 )
    create(:attachment_item, id: 20170205, creator_id: 102 )
    create(:attachment_item, id: 20170206, creator_id: 102 )

    @user = create_test_user
    @user.update(grade: 5)
    @profile2 = create_profile
    @profile3 = create_profile
    @profile4 = create_profile
    @profile5 = create_profile

    # create(:medical_insurance_participator, id: 1, user_id: @profile1.user_id, profile_id: @profile1.id, medical_template_id: 1, participate: 'medical_insurance_paticipator.enum_participate.participated', participate_date: '2016/09/01', cancel_date: Time.zone.parse('2016/09/01')+3.year, monthly_deduction: 50 )
    # create(:medical_insurance_participator, id: 2, user_id: @profile2.user_id, medical_template_id: 2, participate: 'medical_insurance_paticipator.enum_participate.participated', participate_date: '2016/09/03', cancel_date: Time.zone.parse('2016/09/03')+3.year, monthly_deduction: 50 )
    # create(:medical_insurance_participator, id: 3, user_id: @profile3.user_id, medical_template_id: 3, participate: 'medical_insurance_paticipator.enum_participate.participated', participate_date: '2016/10/03', cancel_date: Time.zone.parse('2016/10/03')+3.year, monthly_deduction: 50 )
    # create(:medical_insurance_participator, id: 4, user_id: @profile4.user_id, medical_template_id: nil, participate: 'medical_insurance_paticipator.enum_participate.not_participated', participate_date: '2016/10/03', cancel_date: Time.zone.parse('2016/10/03')+3.year, monthly_deduction: 0 )
    # create(:medical_insurance_participator, id: 5, user_id: @profile5.user_id, medical_template_id: nil, participate: 'medical_insurance_paticipator.enum_participate.not_participated', participate_date: '2016/10/03', cancel_date: Time.zone.parse('2016/10/03')+3.year, monthly_deduction: 0 )

    create_medical_template_setting

    hash_employee_grade_to_current_template_id = {}
    MedicalTemplateSetting.first.sections.each do |record|
      hash_employee_grade_to_current_template_id.store(record['employee_grade'].to_s, record['current_template_id'])
    end
    @participator1 = create(:medical_insurance_participator,
                            id: 1,
                            user_id: @user.id,
                            profile_id: @user.profile.id,
                            participate: 'medical_insurance_paticipator.enum_participate.participated',
                            participate_date: Time.zone.parse('2017/07/01'),
                            cancel_date: Time.zone.parse('2017/01/01')+3.months,
                            monthly_deduction: 50 )
    @participator2 = create(:medical_insurance_participator,
                            id: 2,
                            user_id: @profile2.user_id,
                            profile_id: @profile2.id,
                            participate: User.find(@profile2.user_id).grade.to_i != 6 ? 'medical_insurance_paticipator.enum_participate.participated' : 'not_participated',
                            participate_date: Time.zone.parse('2017/01/03'),
                            cancel_date: Time.zone.parse('2017/01/03')+3.months,
                            monthly_deduction: 50 )  rescue nil
    @participator3 = create(:medical_insurance_participator,
                            id: 3,
                            user_id: @profile3.user_id,
                            profile_id: @profile3.id,
                            participate: User.find(@profile3.user_id).grade.to_i != 6 ? 'medical_insurance_paticipator.enum_participate.participated' : 'not_participated',
                            participate_date: Time.zone.parse('2017/02/03'),
                            cancel_date: Time.zone.parse('2017/02/03')+3.months,
                            monthly_deduction: 50 ) rescue nil
    @participator4 = create(:medical_insurance_participator,
                            id: 4,
                            user_id: @profile4.user_id,
                            profile_id: @profile4.id,
                            participate: User.find(@profile4.user_id).grade.to_i != 6 ? 'medical_insurance_paticipator.enum_participate.participated' : 'not_participated',
                            participate_date: Time.zone.parse('2017/01/03'),
                            cancel_date: Time.zone.parse('2017/01/03')+3.months,
                            monthly_deduction: 50 )  rescue nil
    @participator5 = create(:medical_insurance_participator,
                            id: 5,
                            user_id: @profile5.user_id,
                            profile_id: @profile5.id,
                            participate: User.find(@profile5.user_id).grade.to_i != 6 ? 'medical_insurance_paticipator.enum_participate.participated' : 'not_participated',
                            participate_date: Time.zone.parse('2017/02/03'),
                            cancel_date: Time.zone.parse('2017/02/03')+3.months,
                            monthly_deduction: 50 ) rescue nil

    @reimbursement1 = create(:medical_reimbursement, id: 1, reimbursement_year: 2017, user_id: @user.id, apply_date: '2017/01/01', medical_template_id: 1, medical_item_id: 9, document_number: 12123131, document_amount: 200, reimbursement_amount: 200, tracker_id: @profile5.user_id, track_date: Date.today, attachment_item_ids: [20170201,20170202] )
    @reimbursement2 = create(:medical_reimbursement, id: 2, reimbursement_year: 2017, user_id: @profile2.user_id, apply_date: '2017/05/01', medical_template_id: 2, medical_item_id: 6, document_number: 12123132, document_amount: 200, reimbursement_amount: 200, tracker_id: @profile5.user_id, track_date: Date.today, attachment_item_ids: [20170203] )
    @reimbursement3 = create(:medical_reimbursement, id: 3, reimbursement_year: 2017, user_id: @profile3.user_id, apply_date: '2017/03/01', medical_template_id: 3, medical_item_id: 4, document_number: 12123133, document_amount: 200, reimbursement_amount: 200, tracker_id: @profile5.user_id, track_date: Date.today, attachment_item_ids: [20170204] )
    @reimbursement4 = create(:medical_reimbursement, id: 4, reimbursement_year: 2018, user_id: @profile4.user_id, apply_date: '2017/10/05', medical_template_id: 1, medical_item_id: 3, document_number: 12123134, document_amount: 200, reimbursement_amount: 200, tracker_id: @profile5.user_id, track_date: Date.today, attachment_item_ids: [20170205] )
    @reimbursement5 = create(:medical_reimbursement, id: 5, reimbursement_year: 2018, user_id: @profile5.user_id, apply_date: '2017/12/16', medical_template_id: 2, medical_item_id: 2, document_number: 12123135, document_amount: 200, reimbursement_amount: 200, tracker_id: @profile5.user_id, track_date: Date.today, attachment_item_ids: [20170206] )

    @profile = create_profile

    @current_user = User.find(@profile5.user_id)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :MedicalReimbursement, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test "should index" do
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    get medical_reimbursements_url
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    get medical_reimbursements_url
    assert_response :success

    assert_response :success
    assert_equal 5, json_res['data'].count

    get medical_reimbursements_url, params: { empoid: User.find(@user.id).empoid }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get medical_reimbursements_url, params: { user: User.find(@user.id).chinese_name }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get medical_reimbursements_url, params: { departments: 9 }
    assert_response :success
    assert_equal 0, json_res['data'].count

    get medical_reimbursements_url, params: { positions: 39 }
    assert_response :success
    assert_equal 0, json_res['data'].count

    range = { being: '2017/01/01', end: '2017/05/31' }
    get medical_reimbursements_url, params: { apply_date: range }
    assert_response :success
    assert_equal 3, json_res['data'].count

    get medical_reimbursements_url, params: { insurance_type: 'medical_template.enum_insurance_type.suncity_insurance' }
    assert_response :success
    assert_equal 4, json_res['data'].count

    get medical_reimbursements_url, params: { medical_item: 6 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get medical_reimbursements_url, params: { document_number: 12123132 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get medical_reimbursements_url, params: { document_amount: 200 }
    assert_response :success
    assert_equal 5, json_res['data'].count

    get medical_reimbursements_url, params: { reimbursement_amount: 200 }
    assert_response :success
    assert_equal 5, json_res['data'].count

    get medical_reimbursements_url, params: { trackers: @profile5.user_id }
    assert_response :success
    assert_equal 5, json_res['data'].count

    get medical_reimbursements_url, params: {           medical_templates:    1 }
    assert_response :success
    assert_equal 2, json_res['data'].count


    range = { begin: nil, end: Date.today.strftime('%Y/%m/%d') }
    get medical_reimbursements_url, params: { track_date: range }
    assert_response :success
    assert_equal 5, json_res['data'].count
  end

  test "get index sorted" do
    sort_column = 'medical_item'
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    get medical_reimbursements_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    get medical_reimbursements_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get medical_reimbursements_url, params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s

    get medical_reimbursements_url, params: { sort_column: :medical_templates, sort_direction: :desc }
    assert_response :success
    assert_equal json_res['data'][0]['medical_template_id'], MedicalReimbursement.order('medical_template_id desc').first.medical_template_id
  end

  test "should export" do
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    get '/medical_reimbursements/export', params: { sort_column: 'trackers', sort_direction: :asc }
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    get '/medical_reimbursements/export', params: { sort_column: 'trackers', sort_direction: :asc }
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
  end

  test "should create" do
    MedicalReimbursement.destroy_all
    AttachmentItem.destroy_all
    create_params = {
        user_id: @user.id,
        apply_date: '2017/06/01',
        medical_item_id: 2,
        document_number: 12123141,
        document_amount: 10,
        reimbursement_amount: 10,
    }.merge({ attachment_items: [
        {file_name: 'xxx', attachment_id: 1},
        {file_name: 'xxx2', attachment_id: 2}
    ] })
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    post medical_reimbursements_url, params: create_params, as: :json
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    post medical_reimbursements_url, params: create_params, as: :json
    assert_response :success
    assert_equal '12123141', MedicalReimbursement.last.document_number
    assert_not_nil MedicalReimbursement.last.reimbursement_year
    assert_not_nil MedicalReimbursement.last.tracker_id
    assert_not_nil MedicalReimbursement.last.track_date
    assert_equal 2, MedicalReimbursement.last.attachment_items.count
  end

  # test "should show" do
  #   get medical_reimbursement_url(@reimbursement1.id)
  #   assert_response :success
  #   response_record = json_res['data']
  #   assert_not_nil response_record['user']
  #   assert_not_nil response_record['medical_item']
  #   assert_not_nil response_record['medical_item_template']
  #   assert_not_nil response_record['attachment_items']
  # end

  test "should update 1.0" do
    update_params = {
        user_id: 102,
        medical_item_id: 3,
        document_number: 12123142,
        document_amount: 20,
        reimbursement_amount: 20,
    }.merge({ attachment_items: [
        {file_name: 'xxx', attachment_id: 2},
        {file_name: 'xxx2', attachment_id: 2}
    ] })
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_reimbursement_url(@reimbursement1.id), params: update_params, as: :json
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_reimbursement_url(@reimbursement1.id), params: update_params, as: :json
    assert_response 200
    target_record = MedicalReimbursement.find(@reimbursement1.id)
    assert_equal 102, target_record['user_id']
    assert_equal 3, target_record['medical_item_id']
    assert_equal '12123142', target_record['document_number']
    assert_equal 2, MedicalReimbursement.find(@reimbursement1.id).attachment_items.count
  end

  test "should update 2.0" do
    update_params = {
        user_id: 102,
        medical_item_id: 3,
        document_number: 12123142,
        document_amount: 20,
        reimbursement_amount: 20,
    }.merge({ attachment_items: [] })
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    patch medical_reimbursement_url(@reimbursement1.id), params: update_params, as: :json
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    patch medical_reimbursement_url(@reimbursement1.id), params: update_params, as: :json
    assert_response 200
    target_record = MedicalReimbursement.find(@reimbursement1.id)
    assert_equal 102, target_record['user_id']
    assert_equal 3, target_record['medical_item_id']
    assert_equal '12123142', target_record['document_number']
    assert_equal [], MedicalReimbursement.find(@reimbursement1.id).attachment_items
  end

  test "should destroy" do
    assert_difference('MedicalReimbursement.count', -1) do
      MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
      delete medical_reimbursement_url(@reimbursement1.id)
      assert_response 403
      MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
      delete medical_reimbursement_url(@reimbursement1.id)
    end
    assert_response 200
  end

  test "should get field options" do
    get '/medical_reimbursements/field_options'
    assert_response :success
  end

  test "should get SMS/E-mail content" do
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@another_user)
    get "/medical_reimbursements/#{@reimbursement1.id}/send_message"
    assert_response 403
    MedicalReimbursementsController.any_instance.stubs(:current_user).returns(@current_user)
    get "/medical_reimbursements/#{@reimbursement1.id}/send_message"
    assert_response :success
    assert_not_nil json_res['data']['user']['profile']['data']['personal_information']['field_values']['email']
    assert_not_nil json_res['data']['user']['profile']['data']['personal_information']['field_values']['mobile_number']
  end

  test "should show medical items" do
    get "/medical_reimbursements/#{@user.id}/show_medical_items"
    assert_response :success
    assert_not_nil json_res['data']
    assert_not_nil json_res['data'].first['medical_item_template']
  end

  test "if_participate_medical_insurance" do
    get "/medical_reimbursements/#{@user.id}/if_participate_medical_insurance"
    assert_response :success
  end

  test 'get_query_medical_conditions' do
    params = {
      year: 2017,
      user_id: @user.id,
      id: 9
    }
    get '/query_medical_conditions', params: params
    assert_response :success
  end

end
