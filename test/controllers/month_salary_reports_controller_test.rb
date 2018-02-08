require 'test_helper'

class MonthSalaryReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OccupationTaxSetting.load_predefined
    User.destroy_all
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @admin_role.add_permission_by_attribute(:data_on_each_month_salary, :MonthSalaryReport, :macau)
    @admin_role.add_permission_by_attribute(:data_on_all_month_salary, :MonthSalaryReport, :macau)
    @current_user.add_role(@admin_role)
    @current_user_no_role = create(:user)

    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  def month_salary_report
    @month_salary_report ||= month_salary_reports :one
  end

  def test_create
    assert_difference('MonthSalaryReport.count') do
      post month_salary_reports_url, params: { year_month: Time.zone.now }
    end
    assert_response 201
  end

  def test_show
    test_user = create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_year,
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
    create(:location, id: test_user.location_id)
    create(:position, id: test_user.position_id)
    create(:department, id: test_user.department_id)
    test_ca = CareerRecord.create(params)
    ProfileService.stubs(:users4).with(anything).returns(User.where(id: test_user.id))
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test', original_column_order: [1,2])
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_year, salary_type: :on_duty)
    AccountingMonthSalaryReportJob.perform_now(msr)
    test_user.add_role(@admin_role)
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(test_user)
    get month_salary_report_url(msr.id), as: :json
    assert_response :success
    assert_equal json_res['month_salary_report']['id'], msr.id
    patch preliminary_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 200
    assert_equal SalaryValue.find_by_salary_column_id(0).string_value, 'preliminary_examine'

    patch president_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 200
    assert_equal MonthSalaryReport.first.status, 'president_examine'
    assert_equal BankAutoPayReportItem.count, SalaryValue.select(:user_id).distinct.count
    assert_equal PaySlip.count, SalaryValue.select(:user_id).distinct.count
    assert_equal SalaryValue.find_by_salary_column_id(0).string_value, 'president_examine'

    get show_by_options_month_salary_report_url(msr.id), as: :json
    assert_response 200
    assert_equal json_res['3'].first['key'], Time.zone.now.year

    get show_export_month_salary_report_url(msr.id), params: {
      original_column_order: @salary_column_template.original_column_order
    }
    assert_response :success
  end

  def test_update
    MonthSalaryReport.create(year_month: Time.zone.now, salary_type: :on_duty).calculate
    patch month_salary_report_url(MonthSalaryReport.first)
    AccountingMonthSalaryReportJob.perform_now(MonthSalaryReport.first)
    assert_response 200
    assert_equal MonthSalaryReport.first.status, 'completed'
  end

  def test_preliminary_examine
    MonthSalaryReport.create(year_month: Time.zone.now, salary_type: :on_duty).update_columns(status: :completed)
    #user 无权项测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(create_test_user)
    patch preliminary_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 403
    #user 有{action: data, resorce: vp}权限测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(@current_user)
    patch preliminary_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 200
    assert_equal MonthSalaryReport.first.status, 'preliminary_examine'
  end

  def test_president_examine
    MonthSalaryReport.create(year_month: Time.zone.now, salary_type: :on_duty)
    #user 无权项测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(create_test_user)
    patch president_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 403
    #user 有{action: data, resorce: vp}权限测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(@current_user)
    patch president_examine_month_salary_report_url(MonthSalaryReport.first)
    assert_response 200
    assert_equal MonthSalaryReport.first.status, 'president_examine'
  end

  def test_cancel
    MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :on_duty).update_columns(status: :preliminary_examine)

    #user 无权项测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(create_test_user)
    patch cancel_month_salary_report_url(MonthSalaryReport.first)
    assert_response 403

    #user 有{action: data, resorce: vp}权限测试
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(@current_user)
    patch cancel_month_salary_report_url(MonthSalaryReport.first)
    assert_response 200
    assert_equal MonthSalaryReport.first.status, 'completed'
    MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :on_duty)
    assert_equal MonthSalaryReport.count, 1
  end

  def test_index_by_left
    Profile.destroy_all
    User.destroy_all
    test_user = create_test_user
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
    create(:location, id: test_user.location_id)
    create(:position, id: test_user.position_id)
    create(:department, id: test_user.department_id)
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test', original_column_order: [1,2])
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :left)
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
    @welfare_record = WelfareRecord.create(params)
    resignation_record = test_user.resignation_records.create(
      {
        resigned_date: Time.zone.now.beginning_of_day,
        resigned_reason: 'resignation',
        reason_for_resignation: 'job_description',
        employment_status: 'informal_employees',
        department_id: test_user.department_id,
        position_id: test_user.position_id,
        notice_period_compensation: true,
        compensation_year: true,
        notice_date: Time.zone.now.strftime('%Y/%m/%d')
      }
    )

    test_user.add_role(@admin_role)
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(test_user)
    get index_by_left_month_salary_reports_url, as: :json
    assert_response :ok
    assert json_res['salary_values'].count > 0
    assert json_res['user_year_month'].count > 0
    assert json_res['user_year_month'].first['string_value'], 'not_granted'
    assert_equal json_res['user_year_month'].first['resignation_record_id'], resignation_record.id
    patch "/month_salary_reports/#{msr.id}/update_by_user/#{test_user.id}", params: {year_month: msr.year_month.strftime('%Y/%m/%d'), resignation_record_id: resignation_record.id}
    assert_response :ok
    assert_equal SalaryValue.where(salary_column_id: 0).first.string_value, 'not_granted'
    patch "/month_salary_reports/#{msr.id}/examine_by_user/#{test_user.id}", params: {year_month: msr.year_month.strftime('%Y/%m/%d'), resignation_record_id: resignation_record.id}
    assert_response :ok
    assert_equal SalaryValue.where(salary_column_id: 0).first.string_value, 'granted'
    params = {
      '1': test_user.empoid
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1
    params = {
      '1': test_user.empoid + '2'
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0

    params = {
      '2': test_user.chinese_name
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '2': test_user.chinese_name + '2'
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0
    params = {
      '7': [test_user.department_id]
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '7': [test_user.department_id + 1]
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0

    params = {
      '5': ['suncity_gaming_promotion_company_limited']
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '5': [test_user.reload.company_name + '1']
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0

    params = {
      '3': [Time.zone.now.year]
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '3': [Time.zone.now.year + 1]
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0

    params = {
      '4': [Time.zone.now.beginning_of_month.month]
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '4': [Time.zone.now.beginning_of_month.month + 1]
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0

    params = {
      '0': ['granted']
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      '0': ['not_granted']
    }

    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 0


    params = {
      sort_column: '1',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '2',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1


    params = {
      sort_column: '3',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '4',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '5',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '6',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1


    params = {
      sort_column: '7',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '8',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    params = {
      sort_column: '9',
      sort_direction: :desc
    }
    get index_by_left_month_salary_reports_url(params), as: :json
    assert_equal json_res['user_year_month'].count, 1

    get index_by_left_options_month_salary_reports_url
    assert_response :ok

    get index_by_left_export_month_salary_reports_url, params: {
      original_column_order: @salary_column_template.original_column_order
    }
    assert_response :success
    get index_by_left_month_salary_reports_url, as: :json
    assert_response :ok
    assert_equal json_res['user_year_month'].count, 1

    test_user_2=  create_test_user
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(test_user_2)
    role = create(:role)
    role.add_permission_by_attribute(:data_on_each_month_salary, :MonthSalaryReport, :macau)
    role.add_permission_by_attribute(:data_on_all_month_salary, :MonthSalaryReport, :macau)
    test_user_2.add_role(role)
    get index_by_left_month_salary_reports_url, as: :json
    assert_response :ok
    assert_equal json_res['user_year_month'].count, 0

  end

  def test_index_and_options
    test_user = create_test_user
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
    create(:location, id: test_user.location_id)
    create(:position, id: test_user.position_id)
    create(:department, id: test_user.department_id)
    test_ca = CareerRecord.create(params)
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :left)
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
    @welfare_record = WelfareRecord.create(params)
    resignation_record = test_user.resignation_records.create(
      {
        resigned_date: Time.zone.now,
        resigned_reason: 'resignation',
        reason_for_resignation: 'job_description',
        employment_status: 'informal_employees',
        department_id: test_user.department_id,
        position_id: test_user.position_id,
        notice_period_compensation: true,
        compensation_year: true,
        notice_date: Time.zone.now.strftime('%Y/%m/%d')
      }
    )
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :on_duty)
    AccountingMonthSalaryReportJob.perform_now(msr)
    test_user.add_role(@admin_role)
    MonthSalaryReportsController.any_instance.stubs(:current_user).returns(test_user)
    get month_salary_reports_url, as: :json
    assert_response :ok
    assert json_res['salary_values'].count == 0
    assert json_res['user_year_month'].count == 0

    get options_month_salary_reports_url
    assert_response :ok
    assert_equal json_res['month_salary_reports'][0]['salary_type'], 'on_duty'
  end




  # def test_destroy
  #   assert_difference('MonthSalaryReport.count', -1) do
  #     delete month_salary_report_url(month_salary_report)
  #   end
  #
  #   assert_response 204
  # end
end
