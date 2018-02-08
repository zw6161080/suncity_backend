require 'test_helper'

class EmployeeFundSwitchingReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create_test_user(100)
    another_user =     create_test_user(101)

    EmployeeFundSwitchingReportItem.generate(@current_user)
    EmployeeFundSwitchingReportItem.generate(another_user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :provident_fund, :macau)
    @current_user.add_role(@admin_role)
    @another_user = another_user
  end

  test "should get index" do
    profile = create_test_user.profile
    User.any_instance.stubs(:career_entry_date).returns(Time.zone.now.beginning_of_day)
    ProvidentFund.create({participation_date: Time.zone.now.beginning_of_day, member_retirement_fund_number: 'number_1', is_an_american: true,
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: profile.user_id})
    EmployeeFundSwitchingReportItem.generate(profile.user)
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get employee_fund_switching_report_items_url, as: :json
    assert_response 403
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get employee_fund_switching_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      EmployeeFundSwitchingReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
    if   json_res['data'][11]['user']['profile']['provident_fund']
      assert_equal json_res['data'][11]['user']['profile']['provident_fund']['member_retirement_fund_number'], 'number_1'
    end


    queries = {
      participation_date: {
        begin: Time.zone.now.strftime('%Y/%m/%d'),
        end: Time.zone.now.strftime('%Y/%m/%d')
      }
    }
    get employee_fund_switching_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 8, json_res['data'].count

    queries = {
      participation_date: {
        begin: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
        end: (Time.zone.now + 1.day).strftime('%Y/%m/%d')
      }
    }
    get employee_fund_switching_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    get "#{employee_fund_switching_report_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_employee_fund_switching_report_items_url, as: :json
    assert_response 403
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get columns_employee_fund_switching_report_items_url, as: :json
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
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get options_employee_fund_switching_report_items_url, as: :json
    assert_response 403
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get options_employee_fund_switching_report_items_url, as: :json
    assert_response :success
    EmployeeFundSwitchingReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
        employee_id: @current_user.empoid,
    }
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get employee_fund_switching_report_items_url(**queries), as: :json
    assert_response 403
    EmployeeFundSwitchingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get employee_fund_switching_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 4, json_res['data'].count
    assert json_res['data'].all? do |row|
      EmployeeFundSwitchingReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end



  end

end
