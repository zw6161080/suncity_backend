# coding: utf-8
require 'test_helper'

class SalaryTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    single_department = create(:department, id: 1)
    single_department.positions << create(:position, id: 1)
    single_department.positions << create(:position, id: 2)
    15.times do |i|
      create(:salary_template, template_chinese_name: '模板1.'+i.to_s, template_english_name: 'template_one.'+i.to_s,
             basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300,
             performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500,
             exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0,
             product_bonus: 0, region_bonus: 200, comment: 'test1', belongs_to: {"1" => ["1"]})
      create(:salary_template, template_chinese_name: '模板2.'+i.to_s, template_english_name: 'template_two.'+i.to_s,
             basic_salary: 200, bonus: 1, attendance_award: 0, house_bonus: 60, tea_bonus: 30, kill_bonus: 400,
             performance_bonus: 500, charge_bonus: 800, commission_bonus: 300, receive_bonus: 500,
             exchange_rate_bonus: 200, guest_card_bonus: 300, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0,
             product_bonus: 0, comment: 'test1', region_bonus: 200, belongs_to: {"1" => ["1"]})
    end
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :SalaryTemplate, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test '测试创建模板时不设置部门和职位' do
    create(:salary_template, template_chinese_name: '模板1.', template_english_name: 'template_one.',
           basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300,
           performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500,
           exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0,
           product_bonus: 0, comment: 'test1', region_bonus: 200)
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get '/salary_templates'
    assert_response 403
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get '/salary_templates'
    assert_response :success
  end

  test 'should get index' do
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    get '/salary_templates'
    assert_response 403
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    get '/salary_templates'
    assert_response :success
    assert_equal 20, json_res['data'].count
    assert_equal 30, json_res['meta']['total_count']
    assert_equal 2, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    assert_equal false, json_res['data'][0]['can_be_destroy']
    params ={
      page: 2,
      sort_column: 'basic_salary',
      sort_direction: 'DESC'
    }

    get '/salary_templates', params: params
    assert_response :success
    assert_equal 10, json_res['data'].count
    assert_equal 30, json_res['meta']['total_count']
    assert_equal 2, json_res['meta']['total_page']
    assert_equal 2, json_res['meta']['current_page']
    assert_equal BigDecimal(300), BigDecimal(json_res['data'][0]['attendance_award'])

    params ={
      page: 2,
      sort_column: 'basic_salary',
      sort_direction: 'DESC',
      locale: 'en'
    }

    get '/salary_templates', params: params
    assert_equal "template_one.9", json_res['data'][0]['template_english_name']

    params ={
      page: 1,
      template_name: ["template_one.0"],
      sort_column: 'template_name',
      sort_direction: 'DESC',
      locale: 'en'
    }

    get '/salary_templates', params: params
    assert_response :success


    get '/salary_templates/export'
    assert_response :success
  end

  test 'should get field_options' do
    get '/salary_templates/field_options'
    assert_response :success
    assert_equal json_res['data']['template_name'][0], "模板1.0"
    assert_equal json_res['data']['template_name'][29], "模板2.9"
  end

  test 'should get field_options in english' do
    get '/salary_templates/field_options', params: {locale: 'en'}
    assert_response :success
    assert_equal json_res['data']['template_name'][0], "template_one.0"
    assert_equal json_res['data']['template_name'][29], "template_two.9"
  end

  test 'should get like_field_options' do
    params = {}
    get '/salary_templates/like_field_options', params: params
    assert_response :success
    assert_equal json_res['data'], []
  end

  test 'should get like_field_options with params' do
    params = {
      department_id: 1,
      position_id: 1
    }
    params[:template_name] = '模板1'
    get '/salary_templates/like_field_options', params: params
    assert_response :success
    assert_equal json_res['data'].count, 15
  end

  test 'should get department_and_position_options' do
    get '/salary_templates/department_and_position_options'
    assert_response :success
    assert_equal json_res['data'][0]['department']['id'], 1
  end

  test 'should get get template according to department and position' do
    params = {
      department_id: 1,
      position_id: 1
    }
    get '/salary_templates/find_template_for_department_and_position', params: params
    assert_response :success
    assert_equal json_res['data'].count, SalaryTemplate.all.count
  end


  test 'should post create , get show , patch update and delete destroy' do
    create_params = {
      template_chinese_name: '模板9',
      template_english_name: 'template_ten',
      basic_salary: 6,
      bonus: 1,
      attendance_award: 3000,
      house_bonus: 30,
      tea_bonus: 7,
      kill_bonus: 300,
      performance_bonus: 200,
      charge_bonus: 500,
      commission_bonus: 200,
      receive_bonus: 300,
      exchange_rate_bonus: 200,
      guest_card_bonus: 300,
      respect_bonus: 1000,
      new_year_bonus: 0,
      project_bonus: 0,
      product_bonus: 0,
      region_bonus: 100,
      belongs_to: {"1" => ["1"]},
      comment: 'testset',
      service_award: 0,
      internship_bonus: 0,
      performance_award: 0,
      special_tie_bonus: 0
    }
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@another_user)
    post '/salary_templates', params: create_params, as: :json
    assert_response 403
    SalaryTemplatesController.any_instance.stubs(:current_user).returns(@current_user)
    post '/salary_templates', params: create_params, as: :json
    assert_response :ok
    wf = SalaryTemplate.last
    assert_equal wf.template_chinese_name, '模板9'
    assert_equal wf.bonus, 1
    assert_equal wf.region_bonus.to_s, '100.0'
    assert_equal 31, SalaryTemplate.count

    get "/salary_templates/#{wf.id}"
    assert_response :ok

    assert_equal json_res['data']['id'], wf.id
    assert_equal wf.template_chinese_name, '模板9'

    get '/salary_templates/department_and_position_options'
    assert_response :success
    assert_equal json_res['data'][0]['positions'].count, Position.count

    post '/salary_templates', params: create_params, as: :json
    assert_equal 31, SalaryTemplate.count
    assert_equal "模板9 已經使用", json_res['data'][0]['template_chinese_name'][0]

    create_params[:locale] = "zh-CN"
    post '/salary_templates', params: create_params, as: :json
    assert_equal 31, SalaryTemplate.count
    assert_equal "模板9 已经使用", json_res['data'][0]['template_chinese_name'][0]
    wf = SalaryTemplate.last


    update_params = {
      template_chinese_name: '模板11',
      template_english_name: 'template_eleven',
      basic_salary: 6,
      bonus: 1.5,
      attendance_award: 2000,
      house_bonus: 30,
      tea_bonus: 7,
      kill_bonus: 300,
      performance_bonus: 200,
      charge_bonus: 500,
      commission_bonus: 200,
      receive_bonus: 300,
      exchange_rate_bonus: 200,
      guest_card_bonus: 300,
      respect_bonus: 1000,
      new_year_bonus: 0,
      project_bonus: 0,
      product_bonus: 0,
      region_bonus: 0,
      belongs_to: {"1" => ["2"]},
      comment: 'testset'
    }

    patch "/salary_templates/#{wf.id}", params: update_params, as: :json
    assert_response :ok
    wf= SalaryTemplate.find("#{wf.id}")
    assert_equal wf.region_bonus.to_s, '0.0'
    assert_equal wf.template_chinese_name, '模板11'
    assert_equal wf.attendance_award, BigDecimal(2000)

    update_params = {
      template_chinese_name: '模板1.0',
      template_english_name: 'template_eleven',
      basic_salary: 6,
      bonus: 1.5,
      attendance_award: 2000,
      house_bonus: 30,
      tea_bonus: 7,
      kill_bonus: 300,
      performance_bonus: 200,
      charge_bonus: 500,
      commission_bonus: 200,
      receive_bonus: 300,
      exchange_rate_bonus: 200,
      guest_card_bonus: 300,
      respect_bonus: 1000,
      new_year_bonus: 0,
      project_bonus: 0,
      product_bonus: 0,
      region_bonus: 0,
      belongs_to: {"1" => ["1"]},
      comment: 'testset'
    }
    patch "/salary_templates/#{wf.id}", params: update_params, as: :json
    assert_equal "模板1.0 已經使用", json_res['data'][0]['template_chinese_name'][0]
    assert_difference('SalaryTemplate.count', 0) do
      delete "/salary_templates/#{wf.id}"
      assert_response :ok
    end

  end

end
