# coding: utf-8
require 'test_helper'

class WelfareTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    single_department = create(:department, id: 1)
    single_department.positions <<  create(:position, id: 1)
    single_department.positions <<  create(:position, id: 2)
    5.times do |i|
      create(:welfare_template, template_chinese_name: '模板1.'+i.to_s, template_english_name: 'template_one.'+i.to_s, annual_leave: 0, sick_leave: 0, office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'float', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板2.'+i.to_s, template_english_name: 'template_two.'+i.to_s, annual_leave: 7, sick_leave: 0, office_holiday: 1, holiday_type: 0, probation: 60, notice_period: 30, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'float', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]} )
      create(:welfare_template, template_chinese_name: '模板3.'+i.to_s, template_english_name: 'template_three.'+i.to_s, annual_leave: 15, sick_leave: 6, office_holiday: 2, holiday_type: 0, probation: 90, notice_period: 0, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'float', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板4.'+i.to_s, template_english_name: 'template_four.'+i.to_s, annual_leave: 12, sick_leave: 0, office_holiday: 0, holiday_type: 1, probation: 180, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'float', over_time_salary: 3, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板5.'+i.to_s, template_english_name: 'template_five.'+i.to_s, annual_leave: 7, sick_leave: 0, office_holiday: 1.5, holiday_type: 2, probation: 30, notice_period: 7, double_pay: false, reduce_salary_for_sick: false,  provide_uniform: false, salary_composition: 'float', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板6.'+i.to_s, template_english_name: 'template_six.'+i.to_s, annual_leave: 2, sick_leave: 6, office_holiday: 1.5, holiday_type: 2, probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: true, salary_composition: 'float', over_time_salary: 3, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板7.'+i.to_s, template_english_name: 'template_seven.'+i.to_s, annual_leave: 12, sick_leave: 0, office_holiday: 2, holiday_type: 1, probation: 30, notice_period: 7, double_pay: false, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'float', over_time_salary: 3, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:welfare_template, template_chinese_name: '模板8.'+i.to_s, template_english_name: 'template_eight.'+i.to_s, annual_leave: 15, sick_leave: 6, office_holiday: 1, holiday_type: 1, probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: false,  provide_uniform: false, salary_composition: 'float', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})
    end
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :WelfareTemplate, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test 'can_create' do
    create_params = {
      template_chinese_name: '模板10',
      template_english_name: 'template_ten',
      annual_leave: 12,
      sick_leave: 6,
      office_holiday: 1.5,
      holiday_type: 'none_holiday',
      probation: 30,
      notice_period: 7,
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
      over_time_salary: 1,
      belongs_to: {"1" => ["1"]},
      comment: 'testset',
      position_type: 'business_staff_48',
      work_days_every_week: 5,
    }
    post '/welfare_templates/can_create', params: create_params, as: :json
    assert_response :success
  end

  test 'should get index' do
    WelfareTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get '/welfare_templates'
    assert_response 403
    WelfareTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get '/welfare_templates'
    assert_response :success
    assert_equal 20, json_res['data'].count
    assert_equal false , json_res['data'][0]['can_be_destroy']
    assert_equal 40, json_res['meta']['total_count']
    assert_equal 2, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    params ={
        page: 2,
        holiday_type: [1, 2],
        sort_column: 'holiday_type',
        sort_direction: 'DESC'
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal 5, json_res['data'].count
    assert_equal 25, json_res['meta']['total_count']
    assert_equal 2, json_res['meta']['total_page']
    assert_equal 2, json_res['meta']['current_page']
    sort_array = []

    json_res['data'].each { |hash| sort_array.push(hash['holiday_type']) }
    assert_equal true, sort_array.reverse == sort_array.sort

    params ={
        page: 1,
        holiday_type: [1, 2],
        sort_column: 'holiday_type',
        sort_direction: 'DESC'
    }

    get '/welfare_templates', params: params
    sort_array = []
    json_res['data'].each { |hash| sort_array.push(hash['holiday_type']) }
    assert_equal false, sort_array.reverse == sort_array
    assert_equal true, sort_array.reverse == sort_array.sort

    params ={
        page: 1,
        template_name: ["template_one.0"],
        sort_column: 'template_name',
        sort_direction: 'DESC',
        locale: 'en'
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal   "template_one.0", json_res['data'][0]['template_english_name']
    assert_equal   "template_one.0", json_res['data'][0]['template_name']

    params ={
      position_id: ['1']
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal json_res['data'].count ,20

    params ={
      department_id: ['0']
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal json_res['data'].count ,0

    params ={
      department_id: ['1'],
      position_id: ['1']
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal json_res['data'].count , 20

    params ={
      position_id: ['1'],
      department_id: ['0']
    }

    get '/welfare_templates', params: params
    assert_response :success
    assert_equal json_res['data'].count ,0

    get '/welfare_templates/export'
    assert_response :success


  end

  test 'should get field_options' do
    get '/welfare_templates/field_options'
    assert_response :success
    assert_equal json_res['data']['template_name'][0], "模板1.0"
    assert_equal json_res['data']['template_name'][39], "模板8.4"
  end

  test 'should get field_options in english' do
    get '/welfare_templates/field_options', params: {locale: 'en'}
    assert_response :success
    assert_equal json_res['data']['template_name'][0], "template_eight.0"
    assert_equal json_res['data']['template_name'][39], "template_two.4"
  end

  test 'should get like_field_options' do
    params = {
        department_id: 1,
        position_id: 1
    }
    params[:template_name] = '模板1'
    get '/welfare_templates/like_field_options', params: params
    assert_response :success
    assert_equal json_res['data'].count, 5
  end

  test 'should get get template according to department and position' do
    params = {
      department_id: 1,
      position_id: 1
    }
    get '/welfare_templates/find_template_for_department_and_position', params: params
    assert_response :success
    assert_equal json_res['data'].first['template_chinese_name'], '模板1.0'
  end


  test 'should get like_field_options with params'  do
    params = {}
    get '/welfare_templates/like_field_options', params: params
    assert_response :success
    assert_equal json_res['data'] , []
  end

  test 'should get department_and_position_options' do
    get '/welfare_templates/department_and_position_options'
    assert_response :success
    assert_equal json_res['data'][0]['positions'].count, Position.count
  end

  test 'should post create , get show , patch update and delete destroy' do
    create_params = {
        template_chinese_name: '模板10',
        template_english_name: 'template_ten',
        annual_leave: 12,
        sick_leave: 6,
        office_holiday: 1.5,
        holiday_type: 'none_holiday',
        probation: 30,
        notice_period: 7,
        double_pay: true,
        reduce_salary_for_sick: false,
        provide_uniform: true,
        salary_composition: 'float',
        over_time_salary: 1,
        belongs_to: {"1" => ["1"]},
        comment: 'testset',
        position_type: 'business_staff_48',
        work_days_every_week: 5,
    }
    WelfareTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    post '/welfare_templates', params: create_params, as: :json
    assert_response 403
    WelfareTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    post '/welfare_templates', params: create_params, as: :json
    wf = WelfareTemplate.last
    assert_response :ok
    assert_equal wf.template_chinese_name, '模板10'
    assert_equal wf.holiday_type, 'none_holiday'
    assert_equal 41, WelfareTemplate.count

    post '/welfare_templates', params: create_params, as: :json
    assert_equal 41, WelfareTemplate.count
    assert_equal "模板10 已經使用", json_res['data'][0]['template_chinese_name'][0]

    create_params[:locale] = "zh-CN"
    post '/welfare_templates', params: create_params, as: :json
    assert_equal 41, WelfareTemplate.count
    assert_equal "模板10 已经使用", json_res['data'][0]['template_chinese_name'][0]
    wf= WelfareTemplate.last

    get "/welfare_templates/#{wf.id}"
    assert_response :ok
    assert_equal json_res['data']['id'], wf.id
    assert_equal wf.template_chinese_name, '模板10'
    assert_equal wf.holiday_type, 'none_holiday'

    update_params = {
        template_chinese_name: '模板11',
        template_english_name: 'template_eleven',
        annual_leave: 15,
        sick_leave: 0,
        office_holiday: 1,
        holiday_type: 1,
        probation: 30,
        notice_period: 7,
        double_pay: false,
        reduce_salary_for_sick: true,
        provide_uniform: true,
        salary_composition: 'float',
        over_time_salary: 3,
        belongs_to: {"1" => ["2"]},
        comment: 'testsettwo',
        position_type: 'business_staff_48',
        work_days_every_week: 5,
    }
    patch "/welfare_templates/#{wf.id}", params: update_params, as: :json
    assert_response :ok
    wf= WelfareTemplate.find("#{wf.id}")
    assert_equal wf.template_chinese_name, '模板11'
    assert_equal wf.holiday_type, 'force_holiday'
    assert_equal wf.belongs_to, {"1" => ["2"]}

    get '/welfare_templates/department_and_position_options'
    assert_response :success
    assert_equal json_res['data'][0]['positions'].count, Position.count

    update_params = {
        template_chinese_name: '模板1.0',
        template_english_name: 'template_eleven',
        annual_leave: 15,
        sick_leave: 0,
        office_holiday: 1,
        holiday_type: 1,
        probation: 30,
        notice_period: 7,
        double_pay: false,
        reduce_salary_for_sick: true,
        provide_uniform: true,
        salary_composition: 'float',
        over_time_salary: 3,
        comment: 'testsettwo',
        position_type: 'business_staff_48',
        work_days_every_week: 5,
    }
    patch "/welfare_templates/#{wf.id}", params: update_params, as: :json
    assert_equal "模板1.0 已經使用", json_res['data'][0]['template_chinese_name'][0]

    assert_difference('WelfareTemplate.count', 0) do
      delete "/welfare_templates/#{wf.id}"
      assert_response :ok
    end
  end


end
