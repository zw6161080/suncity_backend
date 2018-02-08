# coding: utf-8
require 'test_helper'

class MedicalInsuranceParticipatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # 已生效
    @template1 = create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    @template2 = create(:medical_template, id: 2, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+2.month)
    @template3 = create(:medical_template, id: 3, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)
    @template4 = create(:medical_template, id: 4, chinese_name: '第四級醫療保險計劃', english_name: 'The fourth level medical insurance plan', simple_chinese_name: '第四级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)
    @template5 = create(:medical_template, id: 5, chinese_name: '第五級醫療保險計劃', english_name: 'The fifth level medical insurance plan', simple_chinese_name: '第五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)

    # 未生效
    @template6 = create(:medical_template, id: 6, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    @template7 = create(:medical_template, id: 7, chinese_name: '第二級醫療保險計劃', english_name: 'The second level medical insurance plan', simple_chinese_name: '第二级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+2.month)
    @template8 = create(:medical_template, id: 8, chinese_name: '第三級醫療保險計劃', english_name: 'The third level medical insurance plan', simple_chinese_name: '第三级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)
    @template9 = create(:medical_template, id: 9, chinese_name: '第四、五級醫療保險計劃', english_name: 'The fourth/fifth level medical insurance plan', simple_chinese_name: '第四、五级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.commercial_insurance', balance_date: Date.today-1.month)

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

    create_medical_template_setting

    @profile1 = create_profile
    @profile2 = create_profile
    @profile3 = create_profile
    MedicalInsuranceParticipator.destroy_all
    create(:department, id: User.find(@profile1.user_id).department_id, chinese_name: '行政及人力資源部')
    create(:position,   id: User.find(@profile1.user_id).position_id,   chinese_name: '網絡及系統副總監')

    hash_employee_grade_to_current_template_id = {}
    MedicalTemplateSetting.first.sections.each do |record|
      hash_employee_grade_to_current_template_id.store(record['employee_grade'].to_s, record['current_template_id'])
    end

    @participator1 = create(:medical_insurance_participator,
                            id: 1,
                            user_id: @profile1.user_id,
                            profile_id:@profile1.id,
                            participate: User.find(@profile1.user_id).grade.to_i != 6 ? 'medical_insurance_paticipator.enum_participate.participated' : 'not_participated',
                            participate_date: Time.zone.parse('2017/01/01'),
                            cancel_date: Time.zone.parse('2017/01/01')+3.months,
                            monthly_deduction: 50 )  rescue nil
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
    @current_user = @profile1.user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :MedicalInsuranceParticipator, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
    MedicalInsuranceParticipatorsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test "should get index" do
    get medical_insurance_participators_url
    assert_response :success
    # 员工编号
    get medical_insurance_participators_url, params: { empoid: User.find(@profile1.user_id).empoid }
    assert_response :success
    assert_equal 1, json_res['data'].count
    template_id = MedicalTemplateSetting.first.sections.select{|hash| hash['employee_grade'] == User.find(@profile1.user_id).grade }.map{|hash| hash['current_template_id']}.first
    assert  json_res['data'][0]['medical_template']['id'], template_id
    # 员工姓名
    get medical_insurance_participators_url, params: { user: @profile1[:data]['personal_information']['field_values']['chinese_name'] }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 部门
    get medical_insurance_participators_url, params: { departments: 9 }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 职位
    get medical_insurance_participators_url, params: { positions: 39 }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 职级
    get medical_insurance_participators_url, params: { grades: @profile1[:data]['position_information']['field_values']['grade'] }
    assert_response :success
    assert_not_nil json_res['data']

    # 入职日期
    range = { begin: 10.year.ago.to_date.to_s.gsub('-','/'), end: Date.today.to_s.gsub('-','/') }
    get medical_insurance_participators_url, params: { date_of_employment: range }
    assert_response :success
    assert_equal 3, json_res['data'].count

    # 是否参加
    get medical_insurance_participators_url, params: { participate: 'medical_insurance_paticipator.enum_participate.participated' }
    assert_response :success
    assert_equal MedicalInsuranceParticipator.where(participate: 'participated').count, json_res['data'].count

    # 参加日期
    range = { begin: '2017/01/01', end: '2017/01/05' }
    get medical_insurance_participators_url, params: { participate_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/01', end: '2018/01/05' }
    get medical_insurance_participators_url, params: { effective_date: range }
    assert_response :success
    assert_equal 3, json_res['data'].count
    get medical_insurance_participators_url, params: { sort_column: :effective_date, sort_direction: :desc}
    assert_response :success

    # 取消日期
    range = { begin: '2017/01/01', end: '2017/01/05' }
    get medical_insurance_participators_url, params: { cancel_date: range }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 医疗模板
    get medical_insurance_participators_url, params: { medical_templates: [@participator3.medical_template_id] }
    assert_response :success
    assert_not_nil json_res['data']

    get medical_insurance_participators_url, params: { medical_templates: [@participator3.medical_template_id * (-1)] }
    assert_response :success
    assert_equal  json_res['data'].count , 0

    # 每月扣除金额
    get medical_insurance_participators_url, params: { monthly_deduction: 50 }
    assert_response :success
    assert_equal 3, json_res['data'].count
  end

  test "get index sorted" do
    sort_column = 'monthly_deduction'
    get medical_insurance_participators_url, params: { sort_column: sort_column, sort_direction: 'asc' }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get medical_insurance_participators_url, params: { sort_column: sort_column, sort_direction: 'desc' }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test "should update and get show" do
    @test_profile = create_profile
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :MedicalInsuranceParticipator, :macau)
    @admin_role.add_permission_by_attribute(:information, :MedicalInsuranceParticipator, :macau)
    user = @test_profile.user
    user.add_role(@admin_role)
    MedicalInsuranceParticipatorsController.any_instance.stubs(:current_user).returns(@test_profile.user)
    patch "/profiles/#{@test_profile.id}/medical_insurance_participator", params: {
        medical_insurance_participator: {
            to_status: 'not_participated_in_the_future',
            valid_date: Time.zone.now.to_s.to_date
        }
    }
    assert_response 200
    assert_equal json_res['data'], true
    assert_equal user.reload.medical_records.size , 0
    assert_equal user.medical_records.count, 0
    get medical_insurance_participators_url
    assert_response :success
    patch "/profiles/#{@test_profile.id}/medical_insurance_participator", params: {
        medical_insurance_participator: {
            to_status: 'participated_in_the_future',
            valid_date: Time.zone.now.to_s.to_date
        }
    }
    assert_response 200
    assert_equal json_res['data'], true
    assert_equal user.reload.medical_records.last.participate , true
    assert_equal user.reload.medical_records.size , 1

    get medical_insurance_participators_url
    assert_response :success
    patch "/medical_insurance_participators/batch_update", params: {ids: [@test_profile.user_id],
                                                                   medical_insurance_participator: {
                                                                       to_status: 'not_participated_in_the_future',
                                                                       valid_date: Date.today + 5
                                                                   }}
    assert_response :success
    assert_equal  MedicalInsuranceParticipator.where(user_id: @test_profile.user_id).first.to_status, 'not_participated_in_the_future'
    assert_equal user.medical_records.last.participate , true
    assert_equal user.medical_records.count, 1
    patch "/profiles/#{@test_profile.id}/medical_insurance_participator", params: {
        medical_insurance_participator: {
            to_status: 'not_participated_in_the_future',
            valid_date: Time.zone.now.to_s.to_date
        }
    }
    assert_response 200
    assert_equal json_res['data'], true
    assert_equal user.reload.medical_records.size , 2
    patch "/medical_insurance_participators/batch_update", params: {ids: [@test_profile.user_id],
                                                                    medical_insurance_participator: {
                                                                        to_status: 'participated_in_the_future',
                                                                        valid_date: Time.zone.now.to_s.to_date
                                                                    }}
    assert_equal MedicalInsuranceParticipator.where(user_id: @test_profile.user_id).first.participate, 'participated'
    assert_equal  MedicalInsuranceParticipator.where(user_id: @test_profile.user_id).first.to_status, nil
    assert_equal user.reload.medical_records.size , 3

    user.remove_role(@admin_role)
    get "/profiles/#{@test_profile.id}/medical_insurance_participator"
    assert_response 403
    user.add_role(@admin_role)
    get "/profiles/#{@test_profile.id}/medical_insurance_participator"

    assert_response :ok

    patch "/profiles/#{@test_profile.id}/medical_insurance_participator", params: {
      medical_insurance_participator: {
        to_status: 'not_participated_in_the_future',
        valid_date: Time.zone.now.to_s.to_date
      }
    }
    assert_response 200
    assert_equal user.reload.medical_records.size , 4
    assert_equal user.medical_records.last.participate , false
  end

  test "should get field options" do
    get '/medical_insurance_participators/field_options'
    assert_response :success
    response_record = json_res['data']
    assert_not_nil response_record['positions']
    assert_not_nil response_record['departments']
    assert_not_nil response_record['grades']
    assert_not_nil response_record['participate']
    assert_not_nil response_record['medical_templates']
    assert_equal '參加', I18n.t(response_record['participate'].first)
    assert_equal '不參加', I18n.t(response_record['participate'].second)
  end

  test "should export" do
    get '/medical_insurance_participators/export', params: { sort_column: 'medical_templates', sort_direction: 'asc' }
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
  end


  test 'auto_update' do
    @test_profile = create_profile
    user = @test_profile.user
    MedicalInsuranceParticipator.create(profile_id: @test_profile.id, user_id: user.id, participate: :not_participated, to_status: :participated_in_the_future, valid_date: Time.zone.now.end_of_day, operator_id: user.id)
    MedicalInsuranceParticipator.auto_update
    assert_equal @test_profile.medical_insurance_participator.participate, 'participated'
    assert_equal @test_profile.medical_insurance_participator.to_status, nil
    assert_equal @test_profile.medical_insurance_participator.monthly_deduction, BigDecimal(50)
  end
  test 'can_create' do
    test_user = create_test_user
    ProfileService.stubs(:date_of_employment).with(any_parameters).returns(Time.zone.now.beginning_of_day)
    get can_create_profile_medical_insurance_participator_url(profile_id: test_user.profile.id, join_date: (Time.zone.now + 1.day).strftime('%Y/%m/%d'))
    assert @response.body
    get can_create_profile_medical_insurance_participator_url(profile_id: test_user.profile.id, join_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'))
    assert_equal  @response.body , 'false'
    get can_create_profile_medical_insurance_participator_url(profile_id: test_user.profile.id, join_date: nil)
    assert_response 422
  end
end
