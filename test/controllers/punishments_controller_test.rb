# coding: utf-8
require 'test_helper'

class PunishmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:department, id: 8,   chinese_name: '行政及人力資源部')
    create(:position,   id: 38,  chinese_name: '網絡及系統副總監')
    create(:location,   id: 368, chinese_name: '辦公室')

    create(:department, id: 9,   chinese_name: '薪酬部')
    create(:position,   id: 39,  chinese_name: '薪酬HR')
    create(:location,   id: 369, chinese_name: '信息安全')

    create(:user, id: 100, empoid: 1, location_id: 368, department_id: 8, position_id: 38, chinese_name: '山姆', english_name: 'Sam')
    create(:user, id: 101, empoid: 2, location_id: 368, department_id: 8, position_id: 38, chinese_name: '莉莉', english_name: 'Lily')
    create(:user, id: 102, empoid: 3, location_id: 369, department_id: 9, position_id: 39, chinese_name: '阿汤哥', english_name: 'Tom')
    create(:user, id: 103, empoid: 4, location_id: 369, department_id: 9, position_id: 39, chinese_name: '杰克船长', english_name: 'Captain Jack')

    create(:approval_item,   id: 20170101, user_id:    101 ) #s多态关联，无需加 'punishment_id: 1'
    create(:approval_item,   id: 20170102, user_id:    101 )
    AttendAttachment.create( id: 20170201, creator_id: 102 )
    AttendAttachment.create( id: 20170202, creator_id: 102 )

    create(:punishment,  created_at: Time.now, user_id: 100, records_in_where: 'not_profile', punishment_status: 'punishment.enum_punishment_status.punishing', punishment_date: '2017/01/01', punishment_category: 'punishment.enum_punishment_category.classA,punishment.enum_punishment_category.grave_fault', punishment_content: 'punishment.punishment_content.c106',
           punishment_result: 'punishment.enum_punishment_result.classA_written_warning', punishment_remarks: '备注信息', incident_time_from: '2017/01/01 15:00',
           incident_time_to: '2017/01/01 19:00', incident_place: '软景中心', incident_discoverer: '王小二', incident_discoverer_phone: '88975678',
           incident_handler: '呂國敏', incident_handler_phone: '77574770', incident_description: '員工黃維他幫助顧客張老三出老千', incident_financial_influence: true,
           incident_money_involved: 10000, incident_customer_involved: true, incident_employee_involved: true, incident_casino_involved: false,
           incident_thirdparty_involved: false, incident_suspended: true, incident_suspended_date: '2017/01/07', target_response_title: '接受處分',
           target_response_content: '願意接受處分。', target_response_datetime_from: '2017/01/05 00:00', target_response_datetime_to: '2017/01/07 00:00', reinstated: true, reinstated_date: '2017/01/10',
           approval_item_ids: [20170101,20170102], attend_attachment_ids: [20170201,20170202], tracker_id: 103, track_date: DateTime.now.strftime('%Y/%m/%d'), profile_abolition_date: '2017/09/09' )
    create(:punishment,  created_at: Time.now, user_id: 101, records_in_where: 'not_profile', punishment_status: 'punishment.enum_punishment_status.punished', punishment_date: '2017/01/03', punishment_category: nil, punishment_content: 'punishment.punishment_content.c105',
           punishment_result: 'punishment.enum_punishment_result.classB_written_warning', punishment_remarks: '备注信息', incident_time_from: '2017/01/02 15:00',
           incident_time_to: '2017/01/02 19:00', incident_place: '央视大楼', incident_discoverer: '飞飞大王', incident_discoverer_phone: '88975678',
           incident_handler: '何炅', incident_handler_phone: '77574770', incident_description: '員工黃維他幫助顧客張老三出老千', incident_financial_influence: true,
           incident_money_involved: 10000, incident_customer_involved: true, incident_employee_involved: true, incident_casino_involved: false,
           incident_thirdparty_involved: false, incident_suspended: true, incident_suspended_date: '2017/01/07', target_response_title: '接受處分',
           target_response_content: '亲戚要不要把自己当外人。', target_response_datetime_from: '2017/01/05 00:00', target_response_datetime_to: '2017/01/07 00:00', reinstated: true, reinstated_date: '2017/01/11',
           approval_item_ids: [20170101,20170102], attend_attachment_ids: [20170201,20170202], tracker_id: 103, track_date: DateTime.now.strftime('%Y/%m/%d'), profile_abolition_date: '2017/09/09' )

    @profile = (test_user = create_test_user).profile
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: Location.last.id,
      position_id: Position.last.id,
      department_id: Department.last.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    @punishment = create(:punishment, created_at: Time.now, user_id: @profile.user_id, records_in_where: 'not_profile', punishment_status: 'punishment.enum_punishment_status.punishing', punishment_date: '2017/01/22', punishment_category: 'punishment.enum_punishment_category.classA,punishment.enum_punishment_category.classB,punishment.enum_punishment_category.grave_fault', punishment_content: 'punishment.punishment_content.c202',
                         punishment_result: 'punishment.enum_punishment_result.cancel_warning_letter', punishment_remarks: '备注信息', incident_time_from: '2017/01/22 15:00',
                         incident_time_to: '2017/01/22 19:00', incident_place: '理工大学', incident_discoverer: '建彪', incident_discoverer_phone: '88975678',
                         incident_handler: '高晓松', incident_handler_phone: '77574770', incident_description: '員工黃維他幫助顧客張老三出老千', incident_financial_influence: true,
                         incident_money_involved: 10000, incident_customer_involved: true, incident_employee_involved: true, incident_casino_involved: false,
                         incident_thirdparty_involved: false, incident_suspended: true, incident_suspended_date: '2017/01/27', target_response_title: '接受處分',
                         target_response_content: '洗洗睡吧。', target_response_datetime_from: '2017/01/24 00:00', target_response_datetime_to: '2017/01/25 00:00', reinstated: true, reinstated_date: '2017/02/05',
                         approval_item_ids: [20170101,20170102], attend_attachment_ids: [20170201,20170202], tracker_id: 103, track_date: DateTime.now.strftime('%Y/%m/%d'), profile_abolition_date: '2017/09/09' )
    create(:department, id: @profile.data['position_information']['field_values']['department'],   chinese_name: '行政及人力資源部')
    create(:position,   id: @profile.data['position_information']['field_values']['position'],  chinese_name: '網絡及系統副總監')
    create(:location,   id: @profile.data['position_information']['field_values']['location'], chinese_name: '辦公室')

    create(:punishment,  created_at: Time.now, user_id: 103, records_in_where: 'not_profile', punishment_status: 'punishment.enum_punishment_status.punished', punishment_date: '2017/01/03', punishment_category: 'punishment.enum_punishment_category.grave_fault', punishment_content: 'punishment.punishment_content.c106,punishment.punishment_content.c224',
           punishment_result: 'punishment.enum_punishment_result.final_written_warning', punishment_remarks: '备注信息', incident_time_from: '2017/01/02 15:00',
           incident_time_to: '2017/01/02 19:00', incident_place: '央视大楼', incident_discoverer: '飞飞大王', incident_discoverer_phone: '88975678',
           incident_handler: '何炅', incident_handler_phone: '77574770', incident_description: '員工黃維他幫助顧客張老三出老千', incident_financial_influence: true,
           incident_money_involved: 10000, incident_customer_involved: true, incident_employee_involved: true, incident_casino_involved: false,
           incident_thirdparty_involved: false, incident_suspended: true, incident_suspended_date: '2017/01/07', target_response_title: '接受處分',
           target_response_content: '亲戚要不要把自己当外人。', target_response_datetime_from: '2017/01/05 00:00', target_response_datetime_to: '2017/01/07 00:00', reinstated: true, reinstated_date: '2017/01/11',
           approval_item_ids: [20170101,20170102], attend_attachment_ids: [20170201,20170202], tracker_id: 103, track_date: DateTime.now.strftime('%Y/%m/%d'), profile_abolition_date: '2017/09/09' )

    create(:punishment,  created_at: Time.now, user_id: 103, records_in_where: 'not_profile', punishment_status: 'punishment.enum_punishment_status.punished', punishment_date: '2017/01/03', punishment_category: 'punishment.enum_punishment_category.classA', punishment_content: 'punishment.punishment_content.c107,punishment.punishment_content.c301',
           punishment_result: 'punishment.enum_punishment_result.fired', punishment_remarks: '备注信息', incident_time_from: '2017/01/02 15:00',
           incident_time_to: '2017/01/02 19:00', incident_place: '央视大楼', incident_discoverer: '飞飞大王', incident_discoverer_phone: '88975678',
           incident_handler: '何炅', incident_handler_phone: '77574770', incident_description: '員工黃維他幫助顧客張老三出老千', incident_financial_influence: true,
           incident_money_involved: 10000, incident_customer_involved: true, incident_employee_involved: true, incident_casino_involved: false,
           incident_thirdparty_involved: false, incident_suspended: true, incident_suspended_date: '2017/01/07', target_response_title: '接受處分',
           target_response_content: '亲戚要不要把自己当外人。', target_response_datetime_from: '2017/01/05 00:00', target_response_datetime_to: '2017/01/07 00:00', reinstated: true, reinstated_date: '2017/01/11',
           approval_item_ids: [20170101,20170102], attend_attachment_ids: [20170201,20170202], tracker_id: 103, track_date: DateTime.now.strftime('%Y/%m/%d'), profile_abolition_date: '2017/09/09' )

    create(:attachment, id: 10000 )
    create(:attachment, id: 10001 )

    # ---------------- punishments in profile
    @profile_punishment1 = create(:punishment,  user_id: 100, records_in_where: 'profile',
                                 profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
                                 punishment_date: '2017/05/06',
                                 punishment_result: 'punishment.enum_punishment_result.classA_written_warning',
                                 punishment_category: 'punishment.enum_punishment_category.classA',
                                 punishment_content: 'punishment.punishment_content.c118',
                                 profile_remarks: '备注',
                                 profile_validity_period: 6,
                                 profile_penalty_score: 2,
                                 profile_abolition_date: '2017/11/06',
                                 tracker_id: 100,
                                 track_date: Time.zone.now)

    @profile_punishment2 = create(:punishment,  user_id: 100, records_in_where: 'profile',
                                  profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
                                  punishment_date: '2017/05/06',
                                  punishment_result: 'punishment.enum_punishment_result.classB_written_warning',
                                  punishment_category: 'punishment.enum_punishment_category.classA',
                                  punishment_content: 'punishment.punishment_content.c211',
                                  profile_remarks: '备注',
                                  profile_validity_period: 12,
                                  profile_penalty_score: 4,
                                  profile_abolition_date: '2018/05/06',
                                  tracker_id: 100,
                                  track_date: Time.zone.now)

    @profile_punishment3 = create(:punishment,  user_id: 100, records_in_where: 'profile',
                                  profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
                                  punishment_date: '2017/05/06',
                                  punishment_result: 'punishment.enum_punishment_result.final_written_warning',
                                  punishment_category: 'punishment.enum_punishment_category.classB',
                                  punishment_content: 'punishment.punishment_content.c321',
                                  profile_remarks: '备注',
                                  profile_validity_period: 24,
                                  profile_penalty_score: nil,
                                  profile_abolition_date: '2019/05/06',
                                  tracker_id: 100,
                                  track_date: Time.zone.now)

    @profile_punishment4 = create(:punishment, user_id: 100, records_in_where: 'profile',
                                  profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
                                  punishment_date: '2017/05/06',
                                  punishment_result: 'punishment.enum_punishment_result.verbal_warning',
                                  punishment_category: 'punishment.enum_punishment_category.classB',
                                  punishment_content: 'punishment.punishment_content.c206',
                                  profile_remarks: '备注',
                                  profile_validity_period: nil,
                                  profile_penalty_score: 0,
                                  profile_abolition_date: nil,
                                  tracker_id: 100,
                                  track_date: Time.zone.now)

    @profile_punishment5 = create(:punishment,  user_id: 100, records_in_where: 'profile',
                                  profile_punishment_status: 'punishment.profile_punishment_status.logout',
                                  punishment_date: '2012/05/06',
                                  punishment_result: 'punishment.enum_punishment_result.final_written_warning',
                                  punishment_category: 'punishment.enum_punishment_category.grave_fault',
                                  punishment_content: 'punishment.punishment_content.c308',
                                  profile_remarks: '备注',
                                  profile_validity_period: 24,
                                  profile_penalty_score: nil,
                                  profile_abolition_date: '2014/05/06',
                                  tracker_id: 100,
                                  track_date: Time.zone.now)

    @profile_punishment6 = create(:punishment, user_id: 100, records_in_where: 'profile',
                                  profile_punishment_status: 'punishment.profile_punishment_status.cancelled',
                                  punishment_date: '2017/05/06',
                                  punishment_result: 'punishment.enum_punishment_result.classB_written_warning',
                                  punishment_category: 'punishment.enum_punishment_category.classB',
                                  punishment_content: 'punishment.punishment_content.c218',
                                  profile_remarks: '备注',
                                  profile_validity_period: 12,
                                  profile_penalty_score: 4,
                                  profile_abolition_date: '2018/05/06',
                                  tracker_id: 100,
                                  track_date: Time.zone.now)

    @current_user = User.find(103)
    @test_profile = create_profile
    @test_profile.user = @current_user

    PunishmentsController.any_instance.stubs(:current_user).returns(@current_user)
    PunishmentsController.any_instance.stubs(:authorize).returns(true)
  end

  test "should get index" do
    get punishments_url
    assert_response :success
    assert_equal 5, json_res['data'].count

    get punishments_url, params: { employee_no: [1,2,3,4], sort_column: 'employee_no', sort_direction: 'desc' }
    assert_response :success
    assert_equal 4, json_res['data'].count
    assert json_res['data'].second['user']['empoid']>json_res['data'].third['user']['empoid']

    get punishments_url, params: { department_id: [8], sort_column: 'department_id', sort_direction: 'asc' }
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].first['user']['department_id'] <= json_res['data'].second['user']['department_id']

    get punishments_url, params: { position_id: [38,39], sort_column: 'position_id', sort_direction: 'desc' }
    assert_response :success
    assert_equal 5, json_res['data'].count
    assert json_res['data'].second['user']['position_id']>=json_res['data'].third['user']['position_id']

    range_begin = '2017/01/01'
    range_end   = '2017/01/05'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get punishments_url, params: { punishment_date: range }
    assert_response :success
    response_record = json_res['data']
    assert_equal 4, response_record.count
    assert response_record.first['punishment_date'].to_datetime >= Time.zone.parse(range[:begin])
    assert response_record.first['punishment_date'].to_datetime <= Time.zone.parse(range[:end])

    get punishments_url, params: { punishment_status: 'punishment.enum_punishment_status.punished' }
    assert_response :success
    response_record = json_res['data']
    assert_equal 3, response_record.count

    get punishments_url, params: { employee_name: 'Sam' }
    assert_response :success
    response_record = json_res['data']
    assert_equal response_record.count, 1

    get punishments_url, params: { department_id: 10000 }
    assert_response :success
    response_record = json_res['data']
    assert_equal response_record.count, 0

    get punishments_url, params: { punishment_category: 'punishment.enum_punishment_category.classA,punishment.enum_punishment_category.grave_fault' }
    assert_response :success
  end

  test "should export" do
    get '/punishments/export', params: { sort_column: 'position_id', sort_direction: 'desc' }
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/json', response.content_type
  end

  test "should create punishment" do
    create_params = {
        user_id: @profile.user_id,
        incident_time_from: "2017/06/23 12:00",
        incident_time_to: "2017/06/23 13:00",
        incident_place: "123456",
        incident_discoverer: "123",
        incident_discoverer_phone: "456",
        incident_handler: "123",
        incident_handler_phone: "132",
        incident_description: "123",
        incident_financial_influence: false,
        incident_employee_involved: false,
        incident_casino_involved: true,
        incident_customer_involved: false,
        incident_money_involved: 0,
        incident_thirdparty_involved: false,
        incident_suspended_date: '2017/01/01',
        punishment_remarks: "",
        incident_suspended: true,
    }

    assert_difference('CareerRecord.count') do
      post punishments_url, params: create_params.merge({  deployment_instructions: '調配說明', comment: '备注' }), as: :json
      assert_response :success
    end
    assert_equal @profile.user_id, Punishment.last.user_id
    assert_not_nil Punishment.last.incident_time_from
    assert_not_nil Punishment.last.incident_time_to
    assert_not_nil Punishment.last.incident_place
    assert_not_nil Punishment.last.incident_discoverer
    assert_not_nil Punishment.last.incident_discoverer_phone
    assert_not_nil Punishment.last.incident_handler
    assert_not_nil Punishment.last.incident_handler_phone
    assert_not_nil Punishment.last.incident_description
    assert_not_nil Punishment.last.incident_financial_influence
    # 新增职程信息

    assert_equal '調配說明', CareerRecord.last.deployment_instructions
  end

  test "should show punishment" do
    get "/punishments/#{@punishment.id}"
    assert_response :success
    assert_not_nil json_res['data']['user_profile']
    response_record = json_res['data']['punishment_infomation']
    assert_not_nil response_record['incident_time_from']
    assert_not_nil response_record['incident_time_to']
    assert_not_nil response_record['incident_place']
    assert_not_nil response_record['incident_discoverer']
    assert_not_nil response_record['incident_discoverer_phone']
    assert_not_nil response_record['incident_handler']
    assert_not_nil response_record['incident_handler_phone']
    assert_not_nil response_record['incident_description']
    assert_not_nil response_record['incident_financial_influence']
    assert_not_nil response_record['user']
  end

  test "should update punishment" do
    approval_items = [
        # { user_id: 101, datetime: '2017/04/05', comment: 'test' },
        # { user_id: 102, datetime: '2017/04/06', comment: 'test 2' }
    ]
    attend_attachments = [
        { file_name: 'test_file_name', creator_id: 100, comment: 'test comment', attachment_id: 10000 },
        { file_name: 'test_file_name_2', creator_id: 100, comment: 'test comment 2', attachment_id: 10001 }
    ]
    update_params = {
        punishment_date: '2016/09/09',
        punishment_result: 'punishment.enum_punishment_result.classA_written_warning',
        punishment_category: 'punishment.enum_punishment_category.grave_fault',
        punishment_content: 'punishment.punishment_content.c105',
        # 新增职程信息
        reinstated: true,
        incident_suspended_date: '2017/01/01',
        reinstated_date: '2017/02/03',
    }
    assert_difference('CareerRecord.count') do
      patch punishment_url(@punishment.id), params: { punishment: update_params }.merge({ attend_attachments: attend_attachments }), as: :json
      assert_response :success
    end

    assert_not_nil Punishment.find(@punishment.id).punishment_date
    assert_not_nil Punishment.find(@punishment.id).punishment_result
    assert_not_nil Punishment.find(@punishment.id).punishment_category
    assert_not_nil Punishment.find(@punishment.id).punishment_content
    assert_equal 'punished', Punishment.find(@punishment.id).punishment_status
    assert_equal 0, Punishment.find(@punishment.id).approval_items.count
    assert_equal 2, Punishment.find(@punishment.id).attend_attachments.count
  end

  test "should destroy punishment" do
    assert_difference('Punishment.count', -1) do
      delete punishment_url(@punishment.id)
    end
    assert_response :success
  end

  test "should get index by empoid or name" do
    get '/punishments/100/index_by_empoid_or_name'
    assert_response :success
  end

  test "fetch field options" do
    get '/punishments/field_options'
    assert_response :success
    response_record = json_res['data']
    assert_not_nil response_record['positions']
    assert_not_nil response_record['departments']
    assert_not_nil response_record['punishment_statuses']
    assert_not_nil response_record['punishment_results']
    assert_not_nil response_record['punishment_categories']
  end

  test "show profile" do
    get '/punishments/show_profile', params: {user_id: @profile.user_id}
    assert_response :success
  end

  test "profile index" do
    PunishmentsController.any_instance.stubs(:current_user).returns(@current_user)
    PunishmentsController.any_instance.stubs(:authorize).returns(true)
    ProfilesController.any_instance.stubs(:current_user).returns(@current_user)
    ProfilesController.any_instance.stubs(:authorize).returns(true)
    get profile_index_punishments_url, params: {user_id: 103}
    assert_response 200
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:information, :Punishment, :macau)
    @current_user.add_role(@admin_role)
    get profile_index_punishments_url, params: {user_id: 103}
    assert_response :success
    assert_equal [], json_res['data']['data']
    assert_equal 0, json_res['data']['current_profile_penalty_score']
    assert_equal '無生效處分', json_res['data']['current_profile_punishment_status']
    assert_nil json_res['data']['current_profile_abolition_date']

    get profile_index_punishments_url, params: {user_id: 100}
    assert_response :success
    assert_equal 6, json_res['data']['data'].count
    assert_equal 6, json_res['data']['current_profile_penalty_score']
    assert_equal '處分生效中', json_res['data']['current_profile_punishment_status']
    assert_not_nil json_res['data']['current_profile_abolition_date']
  end

  test "profile create" do
    post profile_create_punishments_url, params: { punishment: {
        user_id: @profile.user.id,
        profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
        punishment_date: '2017/05/06',
        punishment_result: 'punishment.enum_punishment_result.classA_written_warning',
        punishment_category: 'punishment.enum_punishment_category.classA,punishment.enum_punishment_category.classB',
        punishment_content: 'punishment.punishment_content.c208,punishment.punishment_content.c334',
        profile_remarks: '备注'
    } }, as: :json
    assert_response :success
    assert_not_nil Punishment.last.records_in_where
    assert_not_nil Punishment.last.profile_penalty_score
    assert_not_nil Punishment.last.profile_validity_period
    assert_not_nil Punishment.last.profile_abolition_date
    assert_not_nil Punishment.last.tracker_id
    assert_not_nil Punishment.last.track_date
  end

  test "profile show" do
    get profile_show_punishments_url(id: @profile_punishment1.id)
    assert_response :success
  end

  test "profile update" do
    patch profile_update_punishments_url(id: @profile_punishment1.id), params: { punishment: {
        punishment_result: 'punishment.enum_punishment_result.verbal_warning',
        profile_abolition_date: '2017/08/06'
    } }, as: :json
    assert_response :success
    assert_equal 'verbal_warning', Punishment.find(@profile_punishment1.id).punishment_result
    assert_nil Punishment.find(@profile_punishment1.id).profile_validity_period
    assert_equal 0, Punishment.find(@profile_punishment1.id).profile_penalty_score
  end

  test "profile update 2.0" do
    patch profile_update_punishments_url(id: @profile_punishment1.id), params: { punishment: {
        profile_abolition_date: '2018/07/25',
        profile_punishment_status: 'punishment.profile_punishment_status.logout',
        profile_remarkes: nil,
        punishment_category: 'punishment.enum_punishment_category.classB',
        punishment_content: 'punishment.punishment_content.c204',
        punishment_date: '2017/07/25',
        punishment_result: 'punishment.enum_punishment_result.classB_written_warning',
    } }, as: :json
    assert_response :success
  end

  test "auto_logout_profile_punishment" do
    create(:punishment, id: 12, user_id: 100, records_in_where: 'profile', profile_punishment_status: 'punishment.profile_punishment_status.in_effect',
           punishment_date: '2012/05/06', punishment_result: 'punishment.enum_punishment_result.final_written_warning', punishment_category: 'punishment.enum_punishment_category.grave_fault',
           punishment_content: 'punishment.punishment_content.c308', profile_remarks: '备注', profile_validity_period: 24, profile_penalty_score: nil, profile_abolition_date: '2014/05/06',
           tracker_id: 100, track_date: Time.zone.now)
    Punishment.auto_logout_profile_punishment
    assert_equal 'logout', Punishment.find(12).profile_punishment_status
  end

end
