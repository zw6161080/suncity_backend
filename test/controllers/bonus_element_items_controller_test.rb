require 'test_helper'

class BonusElementItemsControllerTest < ActionDispatch::IntegrationTest
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
    position = create(:position)
    location.departments << department
    location.save!

    @user100.location = location
    @user100.department = department
    @user100.position = position
    @user100.save!

    @user101.location = location
    @user101.department = department
    @user101.position = position
    @user101.save!

    @user102.location = location
    @user102.department = department
    @user102.position = position
    @user102.save!

    BonusElement.load_predefined

    @float_salary_month_entry = FloatSalaryMonthEntry.create_by_year_month(Time.zone.local(2017, 4, 1))
    GeneratingFloatSalaryMonthEntriesJob.perform_now(@float_salary_month_entry)

    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :float_salary, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    ProfileService.stubs(:users7).with(anything).returns(User.all)
    ProfileService.stubs(:float_salary_month_entries_users).with(anything).returns(User.all)
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    post bonus_element_items_float_salary_month_entry_url(id: @float_salary_month_entry.id)
    assert_response :success

    @bonus_element_item = BonusElementItem.first
    BonusElementItemsController.any_instance.stubs(:current_user).returns(@another_user)
    get bonus_element_items_url(
          float_salary_month_entry_id: @float_salary_month_entry.id,
          employee_id: @bonus_element_item.user.empoid,
          employee_name: @bonus_element_item.user.chinese_name,
          location_ids: [ @bonus_element_item.user.location_id ],
          department_ids: [ @bonus_element_item.user.department_id ],
          position_ids: [ @bonus_element_item.user.position_id ],
          sort_column: 'employee_id',
          sort_direction: 'desc'
        ), as: :json
    assert_response 403
    BonusElementItemsController.any_instance.stubs(:current_user).returns(@current_user)
    get bonus_element_items_url(
          float_salary_month_entry_id: @float_salary_month_entry.id,
          employee_id: @bonus_element_item.user.empoid,
          employee_name: @bonus_element_item.user.chinese_name,
          location_ids: [ @bonus_element_item.user.location_id ],
          department_ids: [ @bonus_element_item.user.department_id ],
          position_ids: [ @bonus_element_item.user.position_id ],
          sort_column: 'employee_id',
          sort_direction: 'desc'
        ), as: :json
    assert_response :success


    get "#{bonus_element_items_url}.xlsx", params: {float_salary_month_entry_id:  @float_salary_month_entry.id}
    assert_response :success
  end

  # test "should show bonus_element_item" do
  #   post bonus_element_items_float_salary_month_entry_url(id: @float_salary_month_entry.id)
  #   assert_response :success
  #
  #   @bonus_element_item = BonusElementItem.first
  #
  #   get bonus_element_item_url(@bonus_element_item), as: :json
  #   assert_response :success
  # end

  test "should get options" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    post bonus_element_items_float_salary_month_entry_url(id: @float_salary_month_entry.id)
    assert_response :success

    get options_bonus_element_items_url(float_salary_month_entry_id: @float_salary_month_entry.id)
    assert_response :success
  end
end
