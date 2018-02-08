require 'test_helper'

class BankAutoPayReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    @user = User.find(100)

    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data_on_bank_auto_pay_report_item, :BankAutoPayReportItem, :macau)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @user.add_role(@admin_role)

    BankAutoPayReportItemsController.any_instance.stubs(:current_user).returns(@user)
    create(:bank_auto_pay_report_item,
                                 record_type: 'salary',
                                 year_month: Time.zone.now.beginning_of_month,
                                 balance_date: Time.zone.now.end_of_month,
                                 user_id: 100,
                                 amount_in_mop: BigDecimal.new('100.5'),
                                 amount_in_hkd: BigDecimal.new('200.5'),
                                 begin_work_date: Time.zone.now.beginning_of_month,

                                end_work_date: Time.zone.now.end_of_month,
                                 cash_or_check: 'cash',
                                 leave_in_this_month: false )
  end

  test "should get index" do

    profile = create_test_user.profile
    create(:bank_auto_pay_report_item,
           record_type: 'salary',
           year_month: Time.zone.now.beginning_of_month,
           balance_date: Time.zone.now.end_of_month,
           user_id: profile.user.id,
           amount_in_mop: BigDecimal.new('100.5'),
           amount_in_hkd: BigDecimal.new('200.5'),
           begin_work_date: Time.zone.now.beginning_of_month,
           end_work_date: Time.zone.now.end_of_month)

    get bank_auto_pay_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a?(Array)
    assert data.count > 0
    assert data.all? do |row|
      BankAutoPayReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end

    get "#{bank_auto_pay_report_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    get columns_bank_auto_pay_report_items_url, as: :json
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
    get options_bank_auto_pay_report_items_url, as: :json
    assert_response :success
    BankAutoPayReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
        employee_id: @user.empoid,

    }
    get bank_auto_pay_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res.all? do |row|
      BankAutoPayReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end

    @user.update(grade: 1)
    test_user = create_test_user
    role = create(:role)
    role.add_permission_by_attribute(:data_on_bank_auto_pay_report_item, :BankAutoPayReportItem, :macau)
    test_user.add_role(role)
    BankAutoPayReportItemsController.any_instance.stubs(:current_user).returns(test_user)
    get bank_auto_pay_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count
    BankAutoPayReportItemsController.any_instance.stubs(:current_user).returns(@user)
    queries = {
        cash_or_check: [@user.profile.data['position_information']['field_values']['payment_method']],
    }
    get bank_auto_pay_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count


    queries = {
        cash_or_check: [@user.profile.data['position_information']['field_values']['payment_method'] + 'ads' ],
    }
    get bank_auto_pay_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 0, json_res['data'].count
  end


end
