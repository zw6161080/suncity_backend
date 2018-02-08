require 'test_helper'

class SocialSecurityFundItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    another_user = create_test_user(101)
    @current_user = create_test_user(100)
    params = {
      career_begin: '2017/04/01',
      user_id: @current_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: @current_user.id
    }
    test_ca = CareerRecord.create(params)

    params = {
      career_begin: '2017/04/01',
      user_id: another_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: another_user.id
    }
    test_ca = CareerRecord.create(params)

    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @current_user.add_role(@admin_role)

    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@current_user)

    SocialSecurityFundItem.generate(@current_user, Time.zone.local(2017, 5, 1))
    SocialSecurityFundItem.generate(another_user, Time.zone.local(2017, 5, 1))
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :SocialSecurityFundItem, :macau)
    @current_user.add_role(@admin_role)
    @another_user = another_user
  end

  test "should get index" do
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get social_security_fund_items_url, as: :json
    assert_response 403
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get social_security_fund_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      SocialSecurityFundItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should export xlsx" do
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get "#{social_security_fund_items_url}.xlsx"
    assert_response 403
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get "#{social_security_fund_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get columns_social_security_fund_items_url, as: :json
    assert_response 403
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@current_user)

    get columns_social_security_fund_items_url, as: :json
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
    get options_social_security_fund_items_url, as: :json
    assert_response :success
    SocialSecurityFundItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
      year_month: '2017/05',
      employee_id: @current_user.empoid,
      career_entry_date: {
        begin: @current_user.career_entry_date&.beginning_of_day&.strftime('%Y/%m/%d'),
        end: @current_user.career_entry_date&.end_of_day&.strftime('%Y/%m/%d'),
      },
    }
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get social_security_fund_items_url(**queries), as: :json
    assert_response 403
    SocialSecurityFundItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res['data'].all? do |row|
      SocialSecurityFundItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end

    queries = {
        employee_id: @current_user.empoid,
        career_entry_date: {
            begin: Time.zone.now.strftime('%Y/%m/%d'),
            end: (Time.zone.now + 1.day).strftime('%Y/%m/%d'),
        },
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count
    test_user = create_test_user
    params = {
      career_begin: '2017/04/01',
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    SocialSecurityFundItem.generate(test_user, Time.zone.local(2018, 4, 1))
    queries = {
      year: [2018]
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count


    queries = {
      month: [5]
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count



    queries = {
      chinese_name: @current_user.chinese_name
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

    queries = {
      chinese_name: @current_user.chinese_name + 'test'
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count

    queries = {
      sort_column: :chinese_name,
      sort_direction: :desc
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
    assert_equal json_res['data'][0]['user']['chinese_name'], SocialSecurityFundItem.joins(:user).order('users.chinese_name desc').first.user.chinese_name

    queries = {
      sort_column: :year,
      sort_direction: :desc
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success

    queries = {
      sort_column: :month,
      sort_direction: :desc
    }
    get social_security_fund_items_url(**queries), as: :json
    assert_response :success
  end

  test "should get year month optoins" do
    get year_month_options_social_security_fund_items_url, as: :json
    assert_response :success
  end
end
