require 'test_helper'

class ContributionReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do

    create(:department, id: 100, chinese_name: 'xxx', english_name: 'xxx')
    create(:department, id: 101, chinese_name: 'xxx1', english_name: 'xxx2')
    create(:department, id: 102, chinese_name: 'xxx1', english_name: 'xxx2')
    create(:position, id: 100, chinese_name: 'yyy', english_name: 'yyy')

    @user = create_test_user(user_id: 100)
    params = {
      career_begin: '2017/04/01',
      user_id: @user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: 100,
      department_id: 100,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: @user.id
    }
    test_ca = CareerRecord.create(params)
    @user.update(empoid: '10001')
    another_user = create_test_user(user_id: 101)
    params = {
      career_begin: '2017/04/01',
      user_id: another_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: 101,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: another_user.id
    }
    test_ca = CareerRecord.create(params)
    another_user.update(empoid: '10002')
    test_user = create_test_user(user_id: 102)
    params = {
      career_begin: '2017/04/01',
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: 102,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    test_user.update(empoid: '10003')
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :provident_fund, :macau)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @user.add_role(@admin_role)

    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@user)

    ContributionReportItem.generate(@user, Time.zone.parse('2017/05'), false)
    ContributionReportItem.generate(@user, Time.zone.parse('2017/06'), false)
    ContributionReportItem.generate(another_user, Time.zone.parse('2017/06'), false)

    Report.load_predefined
    User.any_instance.stubs(:career_entry_date).returns(Time.zone.now)
    @another_user = create_test_user
  end

  test "should get index" do
    Profile.destroy_all
    User.destroy_all
    user = create_test_user(user_id: 1020)
    params = {
      career_begin: '2017/04/01',
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: user.id
    }
    test_ca = CareerRecord.create(params)
    profile = user.profile
    ProvidentFund.create({participation_date: Time.zone.now.strftime('%Y/%m/%d'), member_retirement_fund_number: 'number_1', is_an_american: true,
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: user.id})
    ContributionReportItem.generate(profile.user, Time.zone.parse('2017/06'), false)
    profile.user.add_role(@admin_role)
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get contribution_report_items_url, as: :json
    assert_response 403
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(user)
    get contribution_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a?(Array)
    assert data.count > 0
    assert data.all? do |row|
      ContributionReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end


    get "#{contribution_report_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_contribution_report_items_url, as: :json
    assert_response 403
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@user)
    get columns_contribution_report_items_url, as: :json
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
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get options_contribution_report_items_url, as: :json
    assert_response 403
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@user)
    get options_contribution_report_items_url, as: :json
    assert_response :success
    ContributionReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test 'should get year_month_options' do
    get year_month_options_contribution_report_items_url, as: :json
    assert_response :ok
    assert_equal json_res['data'].count , 2
  end

  test "should query data" do
    Profile.destroy_all
    User.destroy_all
    ContributionReportItem.destroy_all
    profile = (@user = create_test_user(100)).profile
    @user.add_role(@admin_role)
    ContributionReportItemsController.any_instance.stubs(:current_user).returns(@user)
    params = {
      career_begin: '2017/04/01',
      user_id: 100,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: 100
    }
    test_ca = CareerRecord.create(params)

    ProvidentFund.create({participation_date: Time.zone.now.strftime('%Y/%m/%d'), member_retirement_fund_number: 'number_1', is_an_american: true,
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: 100})
    ContributionReportItem.generate(profile.user, Time.zone.parse('2017/06'), false)
    profile = create_test_user(101).profile
    params = {
      career_begin: '2017/04/01',
      user_id: 101,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: 101
    }
    test_ca = CareerRecord.create(params)
    ProvidentFund.create({participation_date: Time.zone.now.strftime('%Y/%m/%d'), member_retirement_fund_number: 'number_2', is_an_american: true,
                          has_permanent_resident_certificate: true, supplier: 'to_define', steady_growth_fund_percentage: BigDecimal.new('50'), steady_fund_percentage: BigDecimal.new('50'), a_fund_percentage: '40', b_fund_percentage: '30', profile_id: profile.id, user_id: 101})
    ContributionReportItem.generate(profile.user, Time.zone.parse('2017/06'), false)
    # queries = {
    #     year_month: '2017/06'
    # }
    # get contribution_report_items_url(**queries), as: :json
    # assert_response :success
    # assert_equal 2, json_res['data'].count
    # assert json_res.all? do |row|
    #   ContributionReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    # end
    #
    # queries = {
    #   year_month: ['2017/07']
    # }
    # get contribution_report_items_url(**queries), as: :json
    # assert_response :success
    # assert_equal 0, json_res['data'].count

    queries = {
      report_year_month: '2017/01/01'
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      report_year_month: '2017/06/01'
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    queries = {
      relevant_income: 0
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    queries = {
      relevant_income: 1
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count


    queries = {
      member_retirement_fund_number: 'number_3'
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      member_retirement_fund_number: 'number_1'
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

    queries = {
      sort_column: :member_retirement_fund_number,
      sort_direction: :asc
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal json_res['data'][0]['user']['profile']['provident_fund']['member_retirement_fund_number'], 'number_1'
    queries = {
      sort_column: :member_retirement_fund_number,
      sort_direction: :desc
    }
    get contribution_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal json_res['data'][0]['user']['profile']['provident_fund']['member_retirement_fund_number'], 'number_2'

  end
end
