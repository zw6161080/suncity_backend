require 'test_helper'

class PaySlipsControllerTest < ActionDispatch::IntegrationTest

  setup do
    OccupationTaxSetting.load_predefined
    User.destroy_all
    SalaryColumn.generate

    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_hr, :PaySlip, :macau)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_department, :PaySlip, :macau)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @current_user.add_role(@admin_role)
    @current_user.current_region = 'macau'

    PaySlipsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  def pay_slip
    @pay_slip ||= pay_slips :one
  end

  def test_index
    position = create(:position)
    location = create(:location)
    department = create(:department)
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
    test_user.update(position_id: position.id, department_id: department.id, location_id: location.id)
    PaySlip.create(
      year_month: Time.zone.now, salary_begin: Time.zone.now.beginning_of_month,
      salary_end: Time.zone.now.end_of_month, user_id: test_user.id, entry_on_this_month: true,
      leave_on_this_month: false, salary_type: :on_duty
    )
    get pay_slips_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count , 0


  end

  def test_column
    get columns_pay_slips_url
    assert_response :ok
    assert json_res.count > 0
  end

  def test_options
    get options_pay_slips_url
    assert_response :ok
    assert json_res.keys.count > 1
  end

  def _test_create
    assert_difference('PaySlip.count') do
      post pay_slips_url, params: { pay_slip: {  } }
    end

    assert_response 201
  end

  def test_show
    position = create(:position)
    location = create(:location, id: 1)
    department = create(:department)
    test_user = create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_month,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: location.id,
      position_id: position.id,
      department_id: department.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    test_user.update(position_id: position.id, department_id: department.id, location_id: location.id)
    pay_slip = PaySlip.create(year_month: Time.zone.now.beginning_of_month, salary_begin: Time.zone.now.beginning_of_month,
                   salary_end: Time.zone.now.end_of_month, user_id: test_user.id, entry_on_this_month: true,
                   leave_on_this_month: false, salary_type: :on_duty
    )

    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :on_duty)
    ProfileService.stubs(:users4).with(anything).returns(User.where(id: test_user.id))
    AccountingMonthSalaryReportJob.perform_now(msr)


    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_hr, :PaySlip, :macau)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_department, :PaySlip, :macau)
    @current_user.add_role(@admin_role)
    PaySlipsController.any_instance.stubs(:current_user).returns(@current_user)


    params = {
      name: test_user.chinese_name
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 1

    params = {
      name: test_user.chinese_name * 2
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 0

    params = {
      company_name: ['suncity_gaming_promotion_company_limited']
    }

    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 1

    params = {
      company_name: ['suncity_gaming_promotion_company_limited' * 2]
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 0

    params = {
      empoid: test_user.empoid
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 1

    params = {
      empoid: test_user.empoid * 2
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 0

    params = {
      sort_column: :empoid

    }
    get pay_slips_url(params), as: :json
    assert_response :success

    params = {
      sort_column: :name
    }
    get pay_slips_url(params), as: :json
    assert_response :success

    params = {
      sort_column: :department_id
    }
    get pay_slips_url(params), as: :json
    assert_response :success

    params = {
      sort_column: :company_name
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    test_user_1 = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_hr, :PaySlip, :macau)
    @admin_role.add_permission_by_attribute(:data_on_pay_slip_by_department, :PaySlip, :macau)
    test_user_1.add_role(@admin_role)
    PaySlipsController.any_instance.stubs(:current_user).returns(test_user_1)


    params = {
      name: test_user.chinese_name
    }
    get pay_slips_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count , 0


    PaySlipsController.any_instance.stubs(:current_user).returns(test_user)
    get "#{index_by_mine_pay_slips_url}.json", params: {user_id: test_user.id}
    assert_response :success
    PaySlipsController.any_instance.stubs(:current_user).returns(@current_user)
    get pay_slip_url(pay_slip.id)
    assert_response :success
    PaySlipsController.any_instance.stubs(:current_user).returns(create_test_user)
    get "#{index_by_mine_pay_slips_url}.json", params: {user_id: test_user.id}
    assert_response 200
    get pay_slip_url(pay_slip.id)
    assert_response 403
    PaySlipsController.any_instance.stubs(:current_user).returns(test_user)
    get pay_slip_url({id: pay_slip.id, entry: :mine})
    assert_response 200
  end

  def _test_update
    patch pay_slip_url(pay_slip), params: { pay_slip: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('PaySlip.count', -1) do
      delete pay_slip_url(pay_slip)
    end
    assert_response 204
  end
end
