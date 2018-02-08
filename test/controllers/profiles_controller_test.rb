# coding: utf-8
require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest

  setup do
    MedicalTemplateSetting.load_predefined
    current_user = create_test_user
    single_department = create(:department, id: 13)
    single_department.positions << create(:position, id: 12)
    single_department.positions << create(:position, id: 11)
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:create, :Profile, :macau)
    admin_role.add_permission_by_attribute(:manage, :Profile, :macau)
    admin_role.add_permission_by_attribute(:update_personal_information, :Profile, :macau)
    admin_role.add_permission_by_attribute(:update_position_information, :Profile, :macau)
    current_user.add_role(admin_role)
    ProfilesController.any_instance.stubs(:current_user).returns(current_user)
    ProfilesController.any_instance.stubs(:authorize).returns(true)
    @first_welfare_template = create(
        :welfare_template, template_chinese_name: '模板1', template_english_name: 'template_one', annual_leave: 0, sick_leave: 0,
        office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,
        provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1,
        comment: 'test1')
    @second_welfare_template = create(
        :welfare_template, template_chinese_name: '模板2', template_english_name: 'template_two', annual_leave: 12, sick_leave: 6,
        office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,
        provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1,
        comment: 'test2')
    @first_welfare_template_id = @first_welfare_template.id
    @second_welfare_template_id = @second_welfare_template.id

    @first_salary_template = create(:salary_template, template_chinese_name: 'test1', template_english_name: 'template_one.', basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300, performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500, exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0, product_bonus: 0, comment: 'test1', belongs_to: {"13" => ["12"]})

    @second_salary_template = create(:salary_template, template_chinese_name: 'test2', template_english_name: 'template_two.', basic_salary: 200, bonus: 1, attendance_award: 0, house_bonus: 60, tea_bonus: 30, kill_bonus: 400, performance_bonus: 500, charge_bonus: 800, commission_bonus: 300, receive_bonus: 500, exchange_rate_bonus: 200, guest_card_bonus: 300, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0, product_bonus: 0, comment: 'test1', belongs_to: {"13" => ["11"]})
  end

  test "获取新建档案模版" do
    profile_sections = Config.get('profile_sections')
    key_of_sections = profile_sections.map { |key, value| key }
    params = {
        region: 'manila'
    }

    #获取澳门地区的新建档案模版
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Profile, :macau)
    test_user = create_test_user
    ProfilesController.any_instance.stubs(:current_user).returns(test_user)
    get '/profiles/template', params: params
    assert_response 403
    test_user.add_role(admin_role)
    ProfilesController.any_instance.stubs(:current_user).returns(test_user)
    get '/profiles/template', params: params
    assert_response :ok
    assert_equal key_of_sections, json_res['data'].map { |section| section['key'] }
  end

  test '创建个人档案包含薪酬福利信息(医疗和爱心基金不是当日参加)' do
    SalaryTemplate.destroy_all
    department = create(:department, id: 1, chinese_name: '市場傳播部')
    position = create(:position, id: 1, chinese_name: '網絡及系統副總監')
    department.positions << position
    salary_template = create(:salary_template, template_chinese_name: '模板1.', template_english_name: 'template_one.',
    basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300,
    performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500,
    exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0,
    product_bonus: 0, comment: 'test1', region_bonus: 200)
    welfare_template = create(:welfare_template, template_chinese_name: '模板1.', template_english_name: 'template_one.', annual_leave: 0, sick_leave: 0, office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})

    create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    ProfilesController.any_instance.stubs(:get_medical_template_up_to_grade).with(anything).returns(1)
    create(:location, id: 800 )
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    # post data to create user Profile
    assert_difference(['Profile.count', 'User.count', 'ProfileAttachment.count'], 1) do
      post '/profiles', params: {
        sections: filled_template,
        region: 'macau',
        attachments: [{
                        file_name: 'test file name',
                        attachment_id: create(:attachment).id
                      }],
        welfare_record:{
          welfare_begin: Time.zone.now,
          welfare_template_id: welfare_template.id,
          change_reason: 'entry',
        },
        salary_record: {
          salary_begin: Time.zone.now,
          salary_template_id: salary_template.id,
          change_reason: 'entry',
          basic_salary: '10',
          bonus: '10',
          attendance_award: '10',
          house_bonus: '10',
          new_year_bonus: '10',
          project_bonus: '10',
          product_bonus: '10',
          tea_bonus: '10',
          kill_bonus: '10',
          performance_bonus: '10',
          charge_bonus: '10',
          commission_bonus: '10',
          receive_bonus: '10',
          exchange_rate_bonus: '10',
          guest_card_bonus: '10',
          respect_bonus: '10',
          region_bonus: '10',
        },
        work_experence:{
            company_organazition: 'lala',
            work_experience_position: 'boss',
            work_experience_from: Time.zone.now,
            work_experience_to: Time.zone.now + 1.day,
        },
        education_information:{
            from_mm_yyyy: Time.zone.now,
            to_mm_yyyy: Time.zone.now + 1.day,
            college_university: 'haishi',
            educational_department: 'computer',
            graduate_level: 'shuoshi',
            graduated: true,
        },
        language_skill:{
            language_chinese_writing: 'excellent',
              language_contanese_speaking:  'excellent',
              language_contanese_listening: 'excellent',
              language_mandarin_speaking:   'excellent',
              language_mandarin_listening:  'excellent',
              language_english_speaking:    'excellent',
              language_english_listening:   'excellent',
              language_english_writing:    'excellent',
              language_other_name:         'lala',
              language_other_speaking:      'excellent',
              language_other_listening:     'excellent',
              language_other_writing:       'excellent',
              language_skill:               'haha',
        },
        # 专业资格
        professional_qualifications: [
            { professional_certificate: 'test', orgnaization: 'test', issue_date: Time.zone.now },
            { professional_certificate: 'test', orgnaization: 'test', issue_date: Time.zone.now },
        ],
        # special_schedule_remarks
        special_schedule_remarks: [
            { content: 'test', date_begin: '2017/01/01', date_end: '2017/01/02' }
        ],
        family_member_information:{},
        background_declaration:{
            have_any_relatives: true,
              relative_criminal_record: true,
              relative_criminal_record_detail: 'hh',
              relative_business_relationship_with_suncity: true,
              relative_business_relationship_with_suncity_detail: 'lala',
        },
        family_declaration_item:{
            empoid:1,
            chinese_name:'lala',
            relative_relation:'fuzi'
        },
        wrwt: {
          provide_airfare: true,
          provide_accommodation: true,
          airfare_type: 'count',
          airfare_count: 1,
        },
        love_fund: {
          valid_date: Time.zone.now + 1.day,
          to_status: 'participated_in_the_future'
        },
        medical_insurance_participator: {
          valid_date: Time.zone.now  + 1.day,
          to_status: 'participated_in_the_future'
        },
        shift_status: {
          is_shift: true,
        },
        punch_card_state: {
          is_need: true,
          creator_id: current_user.id,
        },
        roster_instruction: {
          comment: 'test'
        }
           }, as: :json
      assert_response :ok
    end
    profile_id = json_res['data']['id']
    user = Profile.find(profile_id).user
    assert_equal user.group_id, nil
    assert_equal SpecialScheduleRemark.where(user_id: user.id).count, 1
    assert_equal user.chinese_name , user.simple_chinese_name
    assert json_res['data'].key?('id')
      assert_equal RosterInstruction.first.comment, 'test'
      assert_equal SalaryRecord.first.salary_template_id, salary_template.id
      assert_equal WelfareRecord.first.welfare_template_id, welfare_template.id
      assert_equal Wrwt.first.provide_airfare, true
      assert_equal LoveFund.first.participate, 'not_participated'
      assert_equal MedicalInsuranceParticipator.first.participate, 'not_participated'
      assert_equal Profile.find(profile_id).professional_qualifications.count, 2
      get holiday_info_user_url(User.last)
      assert_response :ok



      @current_user = create_test_user
      @admin_role = create(:role)
      @admin_role.add_permission_by_attribute(:personal_information, :Profile, :macau)
      @admin_role.add_permission_by_attribute(:manage, :Profile, :macau)
      @admin_role.add_permission_by_attribute(:position_information, :Profile, :macau)
      @current_user.add_role(@admin_role)
      @current_user.current_region = 'macau'

      @current_user_no_role = create_test_user
      @current_user_no_role.current_region = 'macau'

      ProfilesController.any_instance.stubs(:current_user).returns(@current_user)
      get profile_url({id: profile_id})
      assert_response :ok
      get head_title_profile_url({id: profile_id})
      assert_response :ok


      params = {
        region: :macau, working_status: :entry, status_start_date: Profile.first.data['position_information']['field_values']['date_of_employment'],
        status_end_date: Profile.first.data['position_information']['field_values']['date_of_employment']
      }

      get profiles_url(params)
      assert_response :ok
      assert_equal  json_res['data']['profiles'].count, 1

      params = {
        region: :macau, working_status: :leave, status_start_date: Profile.third.data['position_information']['field_values']['resigned_date'],
        status_end_date: Profile.third.data['position_information']['field_values']['resigned_date']
      }

      get profiles_url(params)
      assert_response :ok
      assert_equal  json_res['data']['profiles'].count, 1

      params = {
        region: :macau, working_status: :in_service, status_start_date: Profile.first.data['position_information']['field_values']['date_of_employment'],
        status_end_date: Profile.first.data['position_information']['field_values']['date_of_employment']
      }

    get profiles_url(params)
    assert_response :ok
    count_1 =   json_res['data']['profiles'].count

    params = {
      region: :macau, working_status: :in_service, status_start_date: (Time.zone.parse(Profile.first.data['position_information']['field_values']['date_of_employment']) - 1.day).strftime('%Y/%m/%d'),
      status_end_date: (Time.zone.parse(Profile.first.data['position_information']['field_values']['date_of_employment']) - 1.day).strftime('%Y/%m/%d')
    }
    get profiles_url(params)
    assert_response :ok
    assert json_res['data']['profiles'].count < Profile.count
  end

  test '创建个人档案包含薪酬福利信息' do
    create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    ProfilesController.any_instance.stubs(:get_medical_template_up_to_grade).with(anything).returns(1)
    create(:department, id: 1, chinese_name: '市場傳播部')
    create(:position, id: 1, chinese_name: '網絡及系統副總監')
    create(:location, id: 800 )
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    # post data to create user Profile
    MedicalInsuranceParticipator.any_instance.stubs(:medical_template_id).returns(1)
    assert_difference(['Profile.count', 'User.count', 'ProfileAttachment.count'], 1) do
      post '/profiles', params: {
        sections: filled_template,
        region: 'macau',
        attachments: [{
                        file_name: 'test file name',
                        attachment_id: create(:attachment).id
                      }],
        welfare_record:{
          welfare_begin: Time.zone.now,
          annual_leave: 0,
          sick_leave: 0,
          office_holiday: 2,
          holiday_type: 'none_holiday',
          probation: 30,
          notice_period: 30,
          double_pay: true,
          reduce_salary_for_sick: true,
          provide_uniform: true,
          salary_composition: 'float',
          over_time_salary: 'one_point_two_times',
          force_holiday_make_up: 'one_money_and_one_holiday',
          change_reason: 'entry',
        },
        salary_record: {
          salary_begin: Time.zone.now,
          change_reason: 'entry',
          basic_salary: '10',
          bonus: '10',
          attendance_award: '10',
          house_bonus: '10',
          new_year_bonus: '10',
          project_bonus: '10',
          product_bonus: '10',
          tea_bonus: '10',
          kill_bonus: '10',
          performance_bonus: '10',
          charge_bonus: '10',
          commission_bonus: '10',
          receive_bonus: '10',
          exchange_rate_bonus: '10',
          guest_card_bonus: '10',
          respect_bonus: '10',
          region_bonus: '10',
        },
        wrwt: {
          provide_airfare: true,
          provide_accommodation: true,
                airfare_type: 'count',
        airfare_count: 1,
        },
        love_fund: {
          valid_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'),
          to_status: 'participated_in_the_future'
        },
        medical_insurance_participator: {
          valid_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'),
          to_status: 'participated_in_the_future'
        }
      }, as: :json
      assert_response :ok

      assert json_res['data'].key?('id')
      assert_equal SalaryRecord.first.status, 'being_valid'
      assert_equal WelfareRecord.first.status, 'being_valid'
      assert_equal Wrwt.first.provide_airfare, true
      assert MedicalInsuranceParticipator.first.participate
      assert MedicalRecord.first.participate
    end
  end

  test '创建个人档案包含薪酬福利信息和愛心基金' do
    create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    ProfilesController.any_instance.stubs(:get_medical_template_up_to_grade).with(anything).returns(1)
    create(:department, id: 1, chinese_name: '市場傳播部')
    create(:position, id: 1, chinese_name: '網絡及系統副總監')
    create(:location, id: 800 )
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    # post data to create user Profile
    assert_difference(['Profile.count', 'User.count', 'ProfileAttachment.count'], 1) do
      post '/profiles', params: {
        sections: filled_template,
        region: 'macau',
        attachments: [{
                        file_name: 'test file name',
                        attachment_id: create(:attachment).id
                      }],
        welfare_record:{
          welfare_begin: Time.zone.now,
          annual_leave: 0,
          sick_leave: 0,
          office_holiday: 2,
          holiday_type: 'none_holiday',
          probation: 30,
          notice_period: 30,
          double_pay: true,
          reduce_salary_for_sick: true,
          provide_uniform: true,
          salary_composition: 'float',
          over_time_salary: 'one_point_two_times',
          force_holiday_make_up: 'one_money_and_one_holiday',
          change_reason: 'entry',
        },
        salary_record: {
          salary_begin: Time.zone.now,
          change_reason: 'entry',
          basic_salary: '10',
          bonus: '10',
          attendance_award: '10',
          house_bonus: '10',
          new_year_bonus: '10',
          project_bonus: '10',
          product_bonus: '10',
          tea_bonus: '10',
          kill_bonus: '10',
          performance_bonus: '10',
          charge_bonus: '10',
          commission_bonus: '10',
          receive_bonus: '10',
          exchange_rate_bonus: '10',
          guest_card_bonus: '10',
          respect_bonus: '10',
          region_bonus: '10',
        },
        wrwt: {
          provide_airfare: false,
          provide_accommodation: true
        },
        love_fund: {
          valid_date: Time.zone.now,
          to_status: 'participated_in_the_future'
        },
        medical_insurance_participator: {
          valid_date: Time.zone.now,
          to_status: 'participated_in_the_future'
        }
      }, as: :json
      assert_response :ok

      assert json_res['data'].key?('id')
      assert_equal SalaryRecord.first.status, 'being_valid'
      assert_equal WelfareRecord.first.status, 'being_valid'
      assert_equal Wrwt.first.provide_airfare, false
      assert_equal LoveFund.first.to_status, 'participated_in_the_future'
      assert LoveFundRecord.first.participate
    end
  end

  test '创建个人档案包含薪酬福利信息和愛心基金(參加愛心基金日期未到)' do
    create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    ProfilesController.any_instance.stubs(:get_medical_template_up_to_grade).with(anything).returns(1)
    create(:department, id: 1, chinese_name: '市場傳播部')
    create(:position, id: 1, chinese_name: '網絡及系統副總監')
    create(:location, id: 800 )
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    # post data to create user Profile
    assert_difference(['Profile.count', 'User.count', 'ProfileAttachment.count'], 1) do
      post '/profiles', params: {
        sections: filled_template,
        region: 'macau',
        attachments: [{
                        file_name: 'test file name',
                        attachment_id: create(:attachment).id
                      }],
        welfare_record:{
          welfare_begin: Time.zone.now,
          annual_leave: 0,
          sick_leave: 0,
          office_holiday: 2,
          holiday_type: 'none_holiday',
          probation: 30,
          notice_period: 30,
          double_pay: true,
          reduce_salary_for_sick: true,
          provide_uniform: true,
          salary_composition: 'float',
          over_time_salary: 'one_point_two_times',
          force_holiday_make_up: 'one_money_and_one_holiday',
          change_reason: 'entry',
        },
        salary_record: {
          change_reason: 'entry',
          salary_begin: Time.zone.now,
          basic_salary: '10',
          bonus: '10',
          attendance_award: '10',
          house_bonus: '10',
          new_year_bonus: '10',
          project_bonus: '10',
          product_bonus: '10',
          tea_bonus: '10',
          kill_bonus: '10',
          performance_bonus: '10',
          charge_bonus: '10',
          commission_bonus: '10',
          receive_bonus: '10',
          exchange_rate_bonus: '10',
          guest_card_bonus: '10',
          respect_bonus: '10',
          region_bonus: '10',
        },
        wrwt: {
          provide_airfare: false,
          provide_accommodation: true
        },
        love_fund: {
          valid_date: Time.zone.now + 1.day,
          to_status: 'participated_in_the_future'
        },
        medical_insurance_participator: {
          valid_date: Time.zone.now,
          to_status: 'participated_in_the_future'
        }
      }, as: :json
      assert_response :ok

      assert json_res['data'].key?('id')
      assert_equal Wrwt.first.provide_airfare, false
      assert_equal LoveFund.first.to_status, 'participated_in_the_future'
      assert_equal LoveFundRecord.count, 0
    end
  end


  test '个人档案查询' do
    profile = create_profile
    select_columns = ['chinese_name', 'english_name']

    get "/profiles", params: {
        location_id: Profile.first.user.location_id,
        select_columns: select_columns,
        region: 'macau'
    }

    assert_response :ok

    assert_equal User.all.where(location_id: Profile.first.user.location_id).count, json_res['data']['profiles'].length

    get "/profiles", params: {
        location_id: -1,
        select_columns: select_columns,
        region: 'macau'
    }
    assert_response :ok
    assert_equal 0, json_res['data']['profiles'].length
  end



  test '修改个人档案' do
    profile = create_profile

    #修改档案节中的字段
    new_pic_url = Faker::Avatar.image('foo')

    params = {
        edit_action_type: 'edit_field',
        params: {
            section_key: 'personal_information',
            field: 'photo',
            new_value: new_pic_url
        }
    }

    patch "/profiles/#{profile.id}", params: params
    assert_response :ok
    profile.reload
    assert_equal new_pic_url, profile.data['personal_information']['field_values']['photo']

    params = {
        edit_action_type: 'edit_field',
        params: {
            section_key: 'position_information',
            field: 'empoid',
            new_value: User.first.empoid
        }
    }

    last_profile = Profile.last
    patch "/profiles/#{last_profile.id}", params: params
    assert_response 422
    last_profile.reload
    assert_equal json_res['data'].first.fetch('message'), "Illegal empoid!"
  end







  test '获取profile列表测试' do
    10.times do
      create_profile
    end

    select_columns = ['chinese_name', 'english_name']

    get '/profiles/', params: {
        select_columns: select_columns,
        region: 'macau'
    }

    assert json_res.key?('meta')
    assert_response :ok
    profiles = json_res['data']['profiles']
    profile = profiles.first
    assert profile.key?('id')
    assert profile.key?('chinese_name')
    assert profile.key?('english_name')
  end

  test '获取部门的profile列表测试' do
    department1 = create(:department, chinese_name: '行政及人力資源部')

    current_user = create(:user, empoid: '111', chinese_name: '呂國敏', grade: 1, department_id: department1.id)

    ProfilesController.any_instance.stubs(:current_user).returns(current_user)
    10.times do
      create_profile
    end

    select_columns = ['chinese_name', 'english_name']

    get '/profiles/index_by_department', params: {
        select_columns: select_columns,
            region: 'macau'
    }
    assert json_res.key?('meta')
    assert_response :ok
  end

  test '普通搜索接口' do
    10.times do
      create_profile
    end

    select_columns = ['chinese_name', 'english_name']

    get '/profiles', params: {
        search_type: 'chinese_name',
        search_data: '姓名',
        region: 'macau',
        select_columns: select_columns,
        employment_statuses: ['formal_employees', 'informal_employees', 'part_time']
    }
    assert_response :ok

    get '/profiles', params: {
        search_type: 'english_name',
        search_data: Faker::Name.first_name,
        region: 'macau',
        select_columns: select_columns
    }
    assert_response :ok

    get '/profiles', params: {
        search_type: 'id_card_number',
        search_data: Faker::Name.first_name,
        region: 'macau',
        select_columns: select_columns
    }
    assert_response :ok

    get '/profiles', params: {
        search_type: 'empoid',
        search_data: '199',
        region: 'macau',
        select_columns: select_columns
    }
    assert_response :ok
  end

  test 'advance search params check' do
    10.times do
      create_profile
    end

    all_chinese_name = User.where(id: Profile.pluck(:user_id)).pluck(:chinese_name)
    #change last element of query array
    all_chinese_name[all_chinese_name.length - 1] = "a-fake-name"
    params = {
        search_type: 'chinese_name',
        search_data: all_chinese_name,
        region: 'macau'
    }

    get '/profiles/advance_search_params_check', params: params
    assert_response :ok
    # one is the current user;
    assert_equal 1, json_res['data']['unmatched_values'].length
  end

  test 'advance search' do
    10.times do
      create_profile
    end
    all_chinese_name = User.where(id: Profile.pluck(:user_id)).pluck(:chinese_name)
    #change last element of query array
    all_chinese_name[all_chinese_name.length - 1] = Faker::Name.name
    select_columns = ['chinese_name', 'english_name']

    params = {
        search_type: 'chinese_name',
        search_data: all_chinese_name,
        region: 'macau',
        select_columns: select_columns
    }

    get '/profiles', params: params
    assert_response :ok
    assert_equal 9, json_res['data']['profiles'].length - 1
  end

  test 'export xls file' do
    10.times do
      create_profile
    end

    all_chinese_name = User.pluck(:chinese_name)
    #change last element of query array
    all_chinese_name[all_chinese_name.length - 1] = Faker::Name.name
    ProfilesController.any_instance.stubs(:current_user).returns(create_test_user)
    ProfilePolicy.any_instance.stubs(:export_xlsx?).returns(true)
    select_columns = [
        "chinese_name", "english_name",
        "nick_name", "last_name", "first_name",
        "middle_name", "photo", "mothers_maiden_name",
        "husbands_last_name", "gender", "national",
        "place_of_birth", "date_of_birth", "id_number",
        "type_of_id", "date_of_expiry"
    ]

    params = {
        fields_lang: 'en',
        search_type: 'chinese_name',
        search_data: all_chinese_name,
        region: 'macau',
        select_columns: select_columns
    }

    get '/profiles/export_xlsx', params: params
    assert_response :ok
  end

  test 'get autocomplete' do
    email_str = 'A'
    User.any_instance.stubs(:profile).returns(create_profile)
    create(:department, id: 9, chinese_name: '行政及人力資源部')
    create(:department, id: 10, chinese_name: '市場傳播部')
    create(:position, id: 39, chinese_name: '網絡及系統副總監')
    create(:position, chinese_name: '總監')
    create(:location, id: 11, chinese_name: '場館一')
    create(:location, chinese_name: '場館二')
    params = {
        key: 'CCC'
    }
    create(:user, id:2 ,email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", department_id: 9, position_id: 39, location_id: 11)
    email_str = email_str.next
    create(:user, id:3 , email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", department_id: 9, position_id: 39, location_id: 11)
    email_str = email_str.next
    create(:user, id:4 , email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", department_id: 9, position_id: 39, location_id: 11)
    email_str = email_str.next
    create(:user, id:5 , email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", department_id: 9, position_id: 39, location_id: 11)
    email_str = email_str.next
    create(:user, id:6 , email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", department_id: 9, position_id: 39, location_id: 11)
    create(:card_profile, user_id: 2)
    create(:card_profile, user_id: 3)
    create(:card_profile, user_id: 4)
    create(:card_profile, user_id: 5)
    create(:card_profile, user_id: 6)

    get '/profiles/autocomplete', params: params

    assert_response :ok
    assert_equal 2, json_res['data']['users'].count
    assert_equal true, json_res['data']["can_cached_in_frontend"]
    json_res['data']['users'].each do |u|
      assert u['fields_join'].match(/CCC/)
      assert u.keys.include? "grade"
    end
  end

  test 'get autocomplete_employees' do
    email_str = 'A'
    create(:department, id: 9, chinese_name: '行政及人力資源部')
    create(:department, id: 10, chinese_name: '市場傳播部')
    create(:position, id: 39, chinese_name: '網絡及系統副總監')
    create(:position, id: 1036, chinese_name: '總監')
    create(:location, id: 11, chinese_name: '場館一')
    create(:location, id: 12, chinese_name: '場館二')
    5.times do
      create(:user, email: "#{email_str * 7}@test.com", chinese_name: "#{email_str.next * 7}", english_name: 'test', department_id: 9, position_id: 39, location_id:11)
      email_str = email_str.next
    end

    params = {
        chinese_name: ['BBBBBBB', 'CCCCCCC', 'joewfj']
    }

    get '/profiles/autocomplete_employees', params: params
    assert_response :ok
    assert_equal 2, json_res['data']['users'].count
    assert_equal true, json_res['data']["can_cached_in_frontend"]
    json_res['data']['users'].each do |u|
      assert u['fields_join'].match(/test/)
    end
    assert_equal ['joewfj'], json_res['data']['not_found_values']
    params = {
        english_name: ['te', 'fsdljk']
    }

    get '/profiles/autocomplete_employees', params: params
    assert_response :ok
    assert_equal 5, json_res['data']['users'].count
    assert_equal true, json_res['data']["can_cached_in_frontend"]
    json_res['data']['users'].each do |u|
      assert u['fields_join'].match(/test/)
    end
    assert_equal 'fsdljk', json_res['data']['not_found_values'][0]
  end

  test 'get attachment_missing' do
    profile = create_profile

    position = create(:position, id: profile.user.position_id)
    department = create(:department, id: profile.user.department_id)

    profile.reload

    sample_type = create(:profile_attachment_type)
    sample_type2 = create(:profile_attachment_type)
    sample_type.profile_attachments << profile.profile_attachments.new

    assert_equal [sample_type.id], profile.filled_attachment_types

    params = {
        region: 'macau'
    }

    get '/profiles/attachment_missing', params: params
    assert_response :ok
    assert json_res['data'].length, 1

    sample_type2.profile_attachments << profile.profile_attachments.new
    assert_equal [sample_type.id, sample_type2.id], profile.filled_attachment_types

    get '/profiles/attachment_missing', params: params
    assert json_res['data'].length, 0
  end

  test 'get attachment_missing_export' do
    profile = create_test_user.profile

    sample_type = create(:profile_attachment_type)
    profile.profile_attachments.create(profile_attachment_type_id: sample_type.id)
    assert_equal [sample_type.id], profile.filled_attachment_types

    params = {
        region: 'macau'
    }

    get '/profiles/attachment_missing_export', params: params
    assert_response :ok
  end

  test 'post update profile attachment_missing_sms_sent to true' do
    profile = create_profile
    assert_equal profile.attachment_missing_sms_sent, false

    post "/profiles/#{profile.id}/attachment_missing_sms_sent"

    profile.reload
    assert_equal profile.attachment_missing_sms_sent, true
  end

  test '输入求职者证件号码查询个人档案 无applicant_profile 创建profile' do
    get '/profiles/query_applicant_profile_id_card_number', params: {
        id_card_number: 'id_card_number'
    }

    assert_response :ok
    assert_equal 'create_profile', json_res['data']['action']
  end

  test '输入求职者证件号码查询个人档案 已有profile 编辑profile' do
    applicant_profile = create_applicant_profile
    id_card_number = applicant_profile.id_card_number
    profile = create_profile
    profile.user.id_card_number = id_card_number
    profile.user.save

    #无profile 创建profile
    get '/profiles/query_applicant_profile_id_card_number', params: {
        id_card_number: id_card_number
    }
    assert_response :ok
    assert_equal 'edit_profile', json_res['data']['action']
    assert_equal profile.id, json_res['data']['profile_id']
  end

  test '输入求职者证件号码查询个人档案 无profile 可以以applicant_profile为模版' do
    Position.all{|item| item.destroy}
    Department.all{|item| item.destroy}
    applicant_profile = create_applicant_profile
    id_card_number = applicant_profile.id_card_number

    get '/profiles/query_applicant_profile_id_card_number', params: {
        id_card_number: id_card_number
    }
    assert_equal 'create_profile', json_res['data']['action']
    assert_equal applicant_profile.id, json_res['data']['applicant_profile_template_id']
  end

  test '显示一个员工的处分记录' do
  end



  test 'my_avatar' do
    profile = create_profile
    ProfilesController.any_instance.stubs(:current_user).returns(profile.user)
    ProfilesController.any_instance.stubs(:authorize).returns(true)
    get '/profiles/my_avatar'
    assert_response :success
  end

end
