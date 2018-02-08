require 'test_helper'

class BonusElementMonthSharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    Location.first.departments << create(:department)
    Location.first.departments << create(:department)
    Location.first.save

    BonusElement.load_predefined
    fs = FloatSalaryMonthEntry.create_by_year_month('2017/01')
    GeneratingFloatSalaryMonthEntriesJob.perform_now(fs)

    @bonus_element_month_share = BonusElementMonthShare.first
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :float_salary, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    BonusElementMonthSharesController.any_instance.stubs(:current_user).returns(@another_user)
    get bonus_element_month_shares_url(float_salary_month_entry_id: FloatSalaryMonthEntry.first.id), as: :json
    assert_response 403
    BonusElementMonthSharesController.any_instance.stubs(:current_user).returns(@current_user)
    get bonus_element_month_shares_url(float_salary_month_entry_id: FloatSalaryMonthEntry.first.id), as: :json
    assert_response :success
    get "#{bonus_element_month_shares_url}.xlsx", params: {float_salary_month_entry_id: FloatSalaryMonthEntry.first.id}
    assert_response :success
  end

  test "should update bonus_element_month_share" do
    update_params = { shares: '99.99' }
    BonusElementMonthSharesController.any_instance.stubs(:current_user).returns(@another_user)
    patch bonus_element_month_share_url(@bonus_element_month_share), params: { bonus_element_month_share: update_params }, as: :json
    assert_response 403
    BonusElementMonthSharesController.any_instance.stubs(:current_user).returns(@current_user)
    patch bonus_element_month_share_url(@bonus_element_month_share), params: { bonus_element_month_share: update_params }, as: :json
    assert_response 200
    @bonus_element_month_share.reload
    assert_equal BigDecimal.new('99.99'), @bonus_element_month_share.shares
  end

  # test "should batch update bonus element month share" do
  #   month_shares = BonusElementMonthShare.all.take(3)
  #   updates = month_shares.map { |s| { id: s.id, shares: '99.99' } }
  #   patch batch_update_bonus_element_month_shares_url, params: { bonus_element_month_share: { updates: updates } }
  #   assert_response :success
  #   month_shares.each do |s|
  #     s.reload
  #     assert_equal BigDecimal.new('99.99'), s.shares
  #   end
  # end
end
