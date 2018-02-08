require 'test_helper'

class ResignationRecordsControllerTest < ActionDispatch::IntegrationTest
  def resignation_record
    @resignation_record ||= resignation_records :one
  end

  def _test_index
    get resignation_records_url
    assert_response :success
  end

  def test_create
    SalaryColumn.generate
    OccupationTaxSetting.load_predefined
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :ResignationRecord, :macau)
    @admin_role.add_permission_by_attribute(:update_history, :ResignationRecord, :macau)
    test_user =  create_test_user

    ResignationRecordsController.any_instance.stubs(:current_user).returns(test_user)
    create(:position, id: 1)
    create(:location, id: 1)
    create(:department, id: 1)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: test_user.location_id,
      position_id: test_user.position_id,
      department_id: test_user.department_id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    params = {
      welfare_begin: Time.zone.now.beginning_of_year,
      change_reason: 'entry',
      annual_leave: 2,
      sick_leave: 2,
      office_holiday: 2,
      holiday_type: 'none_holiday',
      probation: 30,
      notice_period: 30,
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
      over_time_salary: 'one_point_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      user_id: test_user.id
    }
    test_user.add_role(@admin_role)
    @welfare_record = WelfareRecord.create(params)
    assert_difference('ResignationRecord.count') do
      params = {
        user_id: test_user.id,
        resigned_reason: 'resignation',
        reason_for_resignation: 'job_description',
        employment_status: 'informal_employees',
        department_id: test_user.department_id,
        position_id: test_user.position_id,
        notice_period_compensation: true,
        compensation_year: true,
        notice_date: (Time.zone.now -  1.day).strftime('%Y/%m/%d'),
        resigned_date: Time.zone.now.strftime('%Y/%m/%d'),
        final_work_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'),
        notice_period_compensation: true,
        compensation_year: true,
        is_in_whitelist: true,
      }
      post resignation_records_url, params: params
    end

    assert_response 201
    assert_equal SalaryValue.count, SalaryColumn.count

    get resignation_information_options_resignation_records_url
    assert_response :ok
    assert_equal json_res['resigned_reason'], Config.get_all_option_from_selects(:resigned_reason)

    get index_by_user_resignation_records_url({user_id: test_user.id})
    assert_response 200

    test_user.add_role(@admin_role)
    get index_by_user_resignation_records_url({user_id: test_user.id})
    assert_response :ok
    assert_equal json_res.count, 1


    patch resignation_record_url(ResignationRecord.last), params: {  resigned_reason: 'termination' }
    assert_response 200
    assert_equal ResignationRecord.last.resigned_reason, 'termination'


    assert_difference('ResignationRecord.count') do
      params = {
        user_id: test_user.id,
        resigned_reason: 'resignation',
        reason_for_resignation: 'job_description',
        employment_status: 'informal_employees',
        department_id: test_user.department_id,
        position_id: test_user.position_id,
        notice_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'),
        resigned_date: Time.zone.now.strftime('%Y/%m/%d'),
        final_work_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'),
        notice_period_compensation: true,
        compensation_year: true,
        is_in_whitelist: true,
      }
      post resignation_records_url, params: params
    end
    assert_equal SalaryValue.count, SalaryColumn.count * 2

    ResignationRecordsController.any_instance.stubs(:current_user).returns(create_test_user)
    assert_difference('ResignationRecord.count', 0) do
      delete resignation_record_url(ResignationRecord.last)
    end

    assert_response 403
    ResignationRecordsController.any_instance.stubs(:current_user).returns(test_user)
    assert_difference('ResignationRecord.count', -1) do
      ResignationRecord.last.update_columns(status: :invalid)
      delete resignation_record_url(ResignationRecord.last)
    end

    assert_response 204
  end

  def _test_show
    get resignation_record_url(resignation_record)
    assert_response :success
  end

  def _test_update
    patch resignation_record_url(resignation_record), params: { resignation_record: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('ResignationRecord.count', -1) do
      delete resignation_record_url(resignation_record)
    end

    assert_response 204
  end
end
