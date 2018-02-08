require 'test_helper'

class BonusElementItemValuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    User.destroy_all
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)

    @user100 = User.find(100)
    @user101 = User.find(101)
    @user102 = User.find(102)

    department = create(:department)
    location = create(:location)
    location.departments << department
    location.save!

    @user100.location = location
    @user100.department = department
    @user100.save!

    @user101.location = location
    @user101.department = department
    @user101.save!

    @user102.location = location
    @user102.department = department
    @user102.save!

    BonusElement.load_predefined

    fs = FloatSalaryMonthEntry.create_by_year_month(Time.zone.local(2017, 4, 1))
    GeneratingFloatSalaryMonthEntriesJob.perform_now(fs)

    ProfileService.stubs(:users7).with(anything).returns(User.all)
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :float_salary, :macau)
    @current_user.add_role(@admin_role)
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    post bonus_element_items_float_salary_month_entry_url(id: fs.id)
    @bonus_element_item = BonusElementItem.first
    @bonus_element_item_value = @bonus_element_item.bonus_element_item_values.first
    @bonus_element_item_value.amount = '9.99'
    @bonus_element_item_value.shares = '9.99'
    @bonus_element_item_value.per_share = '9.99'
    @bonus_element_item_value.save!


    @another_user = create_test_user
  end

  # test "should show bonus_element_item_value" do
  #   get bonus_element_item_value_url(@bonus_element_item_value), as: :json
  #   assert_response :success
  # end

  test "should update bonus_element_item_value" do
    BonusElementItemValuesController.any_instance.stubs(:current_user).returns(@another_user)
    patch bonus_element_item_value_url(@bonus_element_item_value), params: {
      bonus_element_item_value: {
        amount: @bonus_element_item_value.amount,
        per_share: @bonus_element_item_value.per_share,
        shares: @bonus_element_item_value.shares
      } }, as: :json
    assert_response 403
    BonusElementItemValuesController.any_instance.stubs(:current_user).returns(@current_user)
    patch bonus_element_item_value_url(@bonus_element_item_value), params: {
      bonus_element_item_value: {
        amount: @bonus_element_item_value.amount,
        per_share: @bonus_element_item_value.per_share,
        shares: @bonus_element_item_value.shares
      } }, as: :json
    assert_response 200
  end

end
