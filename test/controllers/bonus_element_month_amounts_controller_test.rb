require 'test_helper'

class BonusElementMonthAmountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    Location.first.departments << create(:department)
    Location.first.departments << create(:department)

    BonusElement.load_predefined
    fs = FloatSalaryMonthEntry.create_by_year_month('2017/01')
    GeneratingFloatSalaryMonthEntriesJob.perform_now(fs)

    @bonus_element_month_amount = BonusElementMonthAmount.first
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :float_salary, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@another_user)
    get bonus_element_month_amounts_url(float_salary_month_entry_id: FloatSalaryMonthEntry.first.id), as: :json
    assert_response 403
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@current_user)
    get bonus_element_month_amounts_url(float_salary_month_entry_id: FloatSalaryMonthEntry.first.id), as: :json
    assert_response :success
    assert json_res.count > 2
    get "#{bonus_element_month_amounts_url}.xlsx", params: {float_salary_month_entry_id: FloatSalaryMonthEntry.first.id}
    assert_response :success
  end

  # test "should show bonus_element_month_amount" do
  #
  #   get bonus_element_month_amount_url(@bonus_element_month_amount), as: :json
  #   assert_response :success
  # end

  test "should update bonus_element_month_amount" do
    update_params = { amount: '99.99' }
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@another_user)
    patch bonus_element_month_amount_url(@bonus_element_month_amount), params: { bonus_element_month_amount: update_params }, as: :json
    assert_response 403
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@current_user)
    patch bonus_element_month_amount_url(@bonus_element_month_amount), params: { bonus_element_month_amount: update_params }, as: :json
    assert_response 200
    @bonus_element_month_amount.reload
    assert_equal BigDecimal.new('99.99'), @bonus_element_month_amount.amount
  end

  test "should batch update bonus element month amount" do
    month_amounts = BonusElementMonthAmount.all.take(3)
    updates = month_amounts.map { |s| { id: s.id, amount: '99.99' } }
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@another_user)
    patch batch_update_bonus_element_month_amounts_url, params: { bonus_element_month_amount: { updates: updates } }
    assert_response 403
    BonusElementMonthAmountsController.any_instance.stubs(:current_user).returns(@current_user)
    patch batch_update_bonus_element_month_amounts_url, params: { bonus_element_month_amount: { updates: updates } }
    assert_response :success
    month_amounts.each do |a|
      a.reload
      assert_equal BigDecimal.new('99.99'), a.amount
    end
  end
end
