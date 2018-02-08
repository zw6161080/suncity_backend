require "test_helper"

class WelfareRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    department = create(:department, id: 1)
    department.positions << create(:position, id: 1)
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @admin_role.add_permission_by_attribute(:information, :welfare_info, :macau)
    @admin_role.add_permission_by_attribute(:history, :WelfareRecord, :macau)
    @admin_role.add_permission_by_attribute(:update_history, :WelfareRecord, :macau)
    @current_user.add_role(@admin_role)
    @current_user.current_region = 'macau'

    @current_user_no_role = create_test_user
    @current_user_no_role.current_region = 'macau'

    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    @profile = create_profile
    @user = @profile.user
    params = {
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
        user_id: @user.id,
    }
    create(:welfare_record, params)
  end

  def test_report_index
    params = { location: @profile.user.location_id }
    get welfare_records_url(params), as: :json
    assert_response :success
  end

  def test_options
    get options_welfare_records_url
    assert_response :success
  end

  def test_columns
    get columns_welfare_records_url
    assert_response :success
  end

  def test_current_welfare_record_by_user_from_job_transfer
    get current_welfare_record_by_user_from_job_transfer_welfare_records_url, params: {user_id: User.first.id}
    assert_response 200
  end

  def test_current_welfare_record_and_coiming_welfare_record
    get current_welfare_record_and_coming_welfare_record_welfare_records_url,params: {user_id: User.first.id}
    assert_response 200
  end

  test 'create_welfare_record; get welfare_records by user; update welfare_record' do
    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    test_user = create_test_user
    test_id = test_user.id
    params = {
      welfare_begin: Time.zone.now + 1.day,
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
      user_id: test_id,
    }
    post welfare_records_url, params: params, as: :json
    assert_response :ok
    assert_equal json_res['welfare_record']['user_id'], test_id

    params = {
      probation: 60
    }
    patch welfare_record_url(WelfareRecord.last), params: params
    assert_response :ok
    assert_equal WelfareRecord.last.probation, 60

    params = {
      user_id: test_id
    }

    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    get current_welfare_record_by_user_welfare_records_url, params: params
    assert_response 403

    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    get current_welfare_record_by_user_welfare_records_url, params: params
    assert_response :ok
    assert_equal json_res['welfare_record']['user_id'], test_id

    params = {
      user_id: test_id
    }
    get index_by_user_welfare_records_url, params: params
    assert_response :ok
    assert_equal json_res.count, 1

    assert_difference('WelfareRecord.count', 0) do
      delete welfare_record_url(WelfareRecord.last)
    end

    assert_response 204

    assert_difference('WelfareRecord.count', 0) do
      delete welfare_record_url(WelfareRecord.last)
    end

    assert_response 204


  end
  test 'create_with template_id' do
    welfare_template = create(:welfare_template, template_chinese_name: '模板1.', template_english_name: 'template_one.', annual_leave: 0, sick_leave: 0, office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})

    test_user = create_test_user
    test_id = test_user.id
    params = {
      welfare_template_id: welfare_template.id,
      change_reason: 'entry',
      user_id: test_id,
      welfare_begin: Time.zone.now
    }
    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    post welfare_records_url, params: params, as: :json
    assert_response :ok
    assert_equal json_res['welfare_record']['user_id'], test_id

    params = {
      user_id: test_id
    }
    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user_no_role)
    get current_welfare_record_by_user_welfare_records_url, params: params
    assert_response 403
    WelfareRecordsController.any_instance.stubs(:current_user).returns(@current_user)
    get current_welfare_record_by_user_welfare_records_url, params: params
    assert_response :ok
  end

  test 'get welfare_information_options' do
    get welfare_information_options_welfare_records_url
    assert_response :ok
    assert_equal json_res['annual_leave'], Config.get_all_option_from_selects(:annual_leave)
  end

end
