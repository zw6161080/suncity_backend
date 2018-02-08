require 'test_helper'

class DepartureEmployeeTaxpayerNumberingReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create_test_user(100)
    another_user =     create_test_user(101)

    DepartureEmployeeTaxpayerNumberingReportItem.generate(@current_user, Time.zone.local(2017, 5, 1))
    DepartureEmployeeTaxpayerNumberingReportItem.generate(another_user, Time.zone.local(2017, 5, 1))
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :provident_fund, :macau)
    @current_user.add_role(@admin_role)
    @another_user = another_user
  end

  test "should get index and update" do
    profile = create_test_user.profile
    User.any_instance.stubs(:career_entry_date).returns(Time.zone.now.beginning_of_day)
    ProvidentFund.create({member_retirement_fund_number: 'number_1', is_an_american: true,
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: profile.user_id})
    DepartureEmployeeTaxpayerNumberingReportItem.generate(profile.user, Time.zone.parse('2017/06'))
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get departure_employee_taxpayer_numbering_report_items_url, as: :json
    assert_response 403
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get departure_employee_taxpayer_numbering_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      DepartureEmployeeTaxpayerNumberingReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
    if json_res['data'][0]['user']['profile']['provident_fund']
      assert_equal json_res['data'][0]['user']['profile']['provident_fund']['member_retirement_fund_number'], 'number_1'
    end
    patch update_beneficiary_name_departure_employee_taxpayer_numbering_report_item_url(DepartureEmployeeTaxpayerNumberingReportItem.first.id), params: {
        beneficiary_name: 'test'
    }
    assert_response :ok
    assert_equal DepartureEmployeeTaxpayerNumberingReportItem.first.beneficiary_name, 'test'
  end

  test "should get columns" do
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_departure_employee_taxpayer_numbering_report_items_url, as: :json
    assert_response 403
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get columns_departure_employee_taxpayer_numbering_report_items_url, as: :json
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
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_departure_employee_taxpayer_numbering_report_items_url, as: :json
    assert_response 403
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get options_departure_employee_taxpayer_numbering_report_items_url, as: :json
    assert_response :success
    DepartureEmployeeTaxpayerNumberingReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
        employee_id: @current_user.empoid,
    }
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response 403
    DepartureEmployeeTaxpayerNumberingReportItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res['data'].all? do |row|
      DepartureEmployeeTaxpayerNumberingReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end

    queries = {
      year_month: ['2017/05'],
    }
    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    queries = {
      year_month: ['2017/06']
    }
    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      sort_column: :employee_name,
      sort_direction: :desc,
    }

    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal DepartureEmployeeTaxpayerNumberingReportItem.joins(:user).order('users.chinese_name desc').first.id, json_res['data'][0]['id']


    queries = {
      sort_column: :tax_number,
      sort_direction: :desc,
    }

    get departure_employee_taxpayer_numbering_report_items_url(**queries), as: :json
    assert_response :success

    get "#{departure_employee_taxpayer_numbering_report_items_url}.xlsx"
    assert_response :success


  end
end
