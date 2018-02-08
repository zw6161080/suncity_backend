# coding: utf-8
require 'test_helper'

class JobTransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    JobTransfersController.any_instance.stubs(:current_user).with(anything).returns(create_test_user)
    JobTransfersController.any_instance.stubs(:authorize).with(anything).returns(true)
  end

  test 'should get index' do

    user = create_test_user

    location = create(:location, id: 1)
    department = create(:department, id: 1)
    position = create(:position, id: 1)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: location.id,
      position_id: position.id,
      department_id: department.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: user.id
    }
    test_ca = CareerRecord.create(params)
    user.update(empoid: '1')
    create(:job_transfer, id: 1, new_location_id: 1, user_id: user.id)

    params_1 ={
      region: 'macau'
    }

    get '/job_transfers', params: params_1
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_pages']
    assert_equal 1, json_res['meta']['current_page']
    user = create_test_user(user_id: 2)
    location = create(:location, id: 2)
    department = create(:department, id: 2)
    position = create(:position, id: 2)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: location.id,
      position_id: position.id,
      department_id: department.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: user.id
    }
    test_ca = CareerRecord.create(params)
    user.update(empoid: '2')
    create(:job_transfer, id: 2, new_location_id: 2, user_id: user.id)
    params_2 ={
        sort_column: 'empoid'
    }
    get '/job_transfers', params: params_2
    assert_response :success
    assert_equal json_res['data'][0]['new_location_id'], 2

    params_3 ={
         empoid: '1'
    }

    get '/job_transfers', params: params_3
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  test 'fetch options' do
    get '/job_transfers/options'
    assert_response :success
  end

  test 'should export_xlsx' do
    user = create_test_user
    location = create(:location, id: 1)
    department = create(:department, id: 1)
    position = create(:position, id: 1)
    create(:job_transfer, id: 1, new_location_id: 1, user_id: user.id)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: location.id,
      position_id: position.id,
      department_id: department.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: user.id
    }
    test_ca = CareerRecord.create(params)

    get '/job_transfers/export_xlsx'
    assert_response :success
  end
end
