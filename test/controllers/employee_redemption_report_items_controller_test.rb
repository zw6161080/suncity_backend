require 'test_helper'

class EmployeeRedemptionReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create_test_user(100)
    another_user =     create_test_user(101)

    EmployeeRedemptionReportItem.generate(@current_user)
    EmployeeRedemptionReportItem.generate(another_user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :provident_fund, :macau)
    @current_user.add_role(@admin_role)
    @another_user = another_user
  end

  test "should get index" do
    profile = create_test_user.profile
    test_user= profile.user
    User.any_instance.stubs(:career_entry_date).returns(Time.zone.now.beginning_of_day)
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
    @welfare_record = WelfareRecord.create(params)

    params = {
      resigned_date: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      resigned_reason: 'resignation',
      reason_for_resignation: 'job_description',
      employment_status: 'informal_employees',
      department_id: test_user.department_id,
      position_id: test_user.position_id,
      notice_period_compensation: true,
      compensation_year: true,
      notice_date: Time.zone.now.strftime('%Y/%m/%d')
    }

    test_ca = ResignationRecord.create(params)
    pf = ProvidentFund.create({participation_date: Time.zone.now, member_retirement_fund_number: 'number_1', is_an_american: true, provident_fund_resignation_date: '2017/10/15',
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: profile.user_id})
    EmployeeRedemptionReportItem.generate(profile.user)
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get employee_redemption_report_items_url, as: :json
    assert_response 403
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get employee_redemption_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      EmployeeRedemptionReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
    queries = {
      provident_fund_resignation_date: {
        begin: '2017/10/15',
        end: '2017/10/15'
      }
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count
    queries = {
      provident_fund_resignation_date: {
        begin: '2017/10/16',
        end: '2017/10/16'
      }
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count


    queries = {
      resigned_date: {
        begin: Time.zone.now.strftime('%Y/%m/%d'),
        end: Time.zone.now.strftime('%Y/%m/%d')
      }
    }


    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count
    queries = {
      resigned_date: {
        begin: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
        end: (Time.zone.now + 1.day).strftime('%Y/%m/%d')
      }
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      resigned_reason: [test_ca.resigned_reason]
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count

    queries = {
      resigned_reason: [test_ca.resigned_reason + 't']
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      chinese_name: test_user.chinese_name
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count

    queries = {
      chinese_name: test_user.chinese_name + 'test'
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      sort_column: :chinese_name,
      sort_direction: :desc
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal json_res['data'][0]['user']['chinese_name'], EmployeeRedemptionReportItem.joins(:user).order('users.chinese_name desc').first.user.chinese_name

    queries = {
      member_retirement_fund_number: 'number_1'
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count


    queries = {
      member_retirement_fund_number: 'number_2'
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count


    queries = {
      sort_column: :resigned_reason,
      sort_direction: :desc
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success


    queries = {
      sort_column: :resigned_date,
      sort_direction: :desc
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success

    queries = {
      sort_column: :bank_of_china_account_mop,
      sort_direction: :desc
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success


    queries = {
      sort_column: :bank_of_china_account_hkd,
      sort_direction: :desc
    }
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success



  end


  test "should get columns" do
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_employee_redemption_report_items_url, as: :json
    assert_response 403
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get columns_employee_redemption_report_items_url, as: :json
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? do |col|
      client_attributes = Config
                              .get('report_column_client_attributes')
                              .fetch('attributes', [])
      assert col.keys.to_set.subset?(client_attributes.to_set)
    end
  end
  test "should get options" do
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get options_employee_redemption_report_items_url, as: :json
    assert_response 403
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get options_employee_redemption_report_items_url, as: :json
    assert_response :success
    EmployeeRedemptionReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    @current_user.profile.reload
    queries = {
        employee_id: @current_user.empoid,
    }
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response 403
    EmployeeRedemptionReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get employee_redemption_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 4, json_res['data'].count
    assert json_res['data'].all? do |row|
      EmployeeRedemptionReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end


    get "#{employee_redemption_report_items_url}.xlsx", params: queries
    assert_response :success
  end
end
