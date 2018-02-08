require 'test_helper'

class SalaryRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @admin_role.add_permission_by_attribute(:information, :SalaryRecord, :macau)
    @admin_role.add_permission_by_attribute(:history, :SalaryRecord, :macau)
    @admin_role.add_permission_by_attribute(:update_history, :SalaryRecord, :macau)
    @current_user.add_role(@admin_role)
    @current_user.current_region = 'macau'

    @current_user_no_role = create_test_user
    @current_user_no_role.current_region = 'macau'
    @profile_1 = create_profile
    @user_1 = @profile_1.user
    params = {
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
        user_id: @user_1.id
    }
    salary_record_1 = create(:salary_record, **params)
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
  end


  def salary_record
    @salary_record ||= salary_records :one
  end

  def test_report_index
    query_params = {
        loation: [@user_1.location_id]
    }
    get salary_records_url, as: :json
    assert_response :success
  end

  def test_current_salary_record_by_user_from_job_transfer
    get current_salary_record_by_user_from_job_transfer_salary_records_url, params: {user_id: User.first.id}
    assert_response 200
  end

  def test_current_salary_record_and_coiming_salary_record
    get current_salary_record_and_coming_salary_record_salary_records_url,params: {user_id: User.first.id}
    assert_response 200
  end

  def test_create
    test_id = create_test_user.id
    params = {
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
        special_tie_bonus: '10',
        performance_award: '10',
        internship_bonus: '10',
        service_award: '10',
        user_id: test_id
    }

    #user 无权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    post salary_records_url, params: params
    assert_response 403
    #user 有{action: data, resource: vp}权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    assert_difference('SalaryRecord.count') do
      post salary_records_url, params: params
    end
    assert_response 201

    #user 无权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    get salary_record_url(SalaryRecord.last)
    assert_response 403
    #user 有{action: data, resource: vp}权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    get salary_record_url(SalaryRecord.last)
    assert_response 200

    params = {
      respect_bonus: '20'
    }
    #user 无权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    patch salary_record_url(SalaryRecord.last), params: params
    assert_response 403
    #user 有{action: data, resource: vp}权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    patch salary_record_url(SalaryRecord.last), params: params
    assert_response 200
    params = {
      user_id: test_id
    }

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    get current_salary_record_by_user_salary_records_url, params: params
    assert_response 403

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    get current_salary_record_by_user_salary_records_url, params: params
    assert_response :ok
    assert_equal json_res['user_id'], test_id

    params = {
      user_id: test_id
    }

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    get index_by_user_salary_records_url, params: params
    assert_response 403

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    @current_user_no_role.stubs(:id).returns(test_id)
    get index_by_user_salary_records_url, params: params.merge({entry: 'mine'})
    assert_response 200

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    @current_user_no_role.stubs(:id).returns(test_id + 1)
    get index_by_user_salary_records_url, params: params.merge({entry: 'mine'})
    assert_response 403

    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    get index_by_user_salary_records_url, params: params
    assert_response :ok
    assert_equal json_res.count , 1

    #user 无权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    delete salary_record_url(SalaryRecord.last)
    assert_response 403
    #user 有{action: data, resource: vp}权限
    SalaryRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    assert_difference('SalaryRecord.count', 0) do
      delete salary_record_url(SalaryRecord.last)
    end

    assert_response 204

    get index_by_user_salary_records_url, params: params
    assert_response :ok
    assert_equal json_res.count , 1

    assert_difference('SalaryRecord.count', 0) do
      delete salary_record_url(SalaryRecord.last)
    end

    assert_response 204

  end

  def test_options
    get salary_information_options_salary_records_url
    assert_response :ok
    assert_equal json_res['unit'],Config.get_all_option_from_selects(:salary_unit)
  end

  def _test_show
    get salary_record_url(salary_record)
    assert_response :success
  end


  def _test_destroy
    assert_difference('SalaryRecord.count', -1) do
      delete salary_record_url(salary_record)
    end

    assert_response 204
  end
end
