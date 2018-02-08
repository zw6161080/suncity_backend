require 'test_helper'

class FloatSalaryMonthEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    User.destroy_all
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)

    @user100 = User.find(100)
    @user101 = User.find(101)
    @user102 = User.find(102)

    @department = create(:department, chinese_name: '測試部門')
    @department2 = create(:department, chinese_name: '測試部門2')
    @location = create(:location, chinese_name: '測試場館')
    @location.departments << @department
    @location.departments << @department2
    @location.save!
    @position = create(:position, chinese_name: '測試職位')

    @user100.location_id = @location.id
    @user100.department_id = @department.id
    @user100.position_id = @position.id

    @user100.save!

    @user101.location_id = @location.id
    @user101.department_id = @department2.id
    @user101.position_id = @position.id
    @user101.save!

    @user102.location_id = @location.id
    @user102.department_id = @department.id
    @user102.position_id = @position.id
    @user102.save!

    User.all.each do |user|
      create(:career_record,
             user_id: user.id, career_begin: '2010/01/01', career_end: nil, location_id: user.location_id,
             department_id: user.department_id, position_id: user.position_id
      )
      create(:salary_record, user_id: user.id, salary_begin: '2010/01/01', salary_end: nil)
    end

    BonusElement.load_predefined

    @start_year_month = Time.zone.local(2018, 1, 1)
    @origin_year_month = @start_year_month
    @float_salary_month_entry = FloatSalaryMonthEntry.create_by_year_month(@origin_year_month)
    GeneratingFloatSalaryMonthEntriesJob.perform_now(@float_salary_month_entry)

    @start_year_month += 1.month
    fs = FloatSalaryMonthEntry.create_by_year_month(@start_year_month)
    GeneratingFloatSalaryMonthEntriesJob.perform_now(fs)
    @start_year_month += 1.month
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :float_salary, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
  end

  test "should get index" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    get float_salary_month_entries_url, as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    get float_salary_month_entries_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a? Array
    data.each do |entry|
      assert_not_nil entry['year_month']
      assert_not_nil entry['status']
      assert_not_nil entry['employees_count']
    end
  end


  test "should import bonus month amount" do
    file = Rack::Test::UploadedFile.new('test/models/bonus_element_month_amount_import_test', 'application/xlsx')
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    post import_amounts_float_salary_month_entry_url(@float_salary_month_entry), { file: file }, as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    post import_amounts_float_salary_month_entry_url(@float_salary_month_entry), { file: file }, as: :json
    assert_response :success
  end



  test "should query by year_month" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    get float_salary_month_entries_url(year_month: @origin_year_month.strftime('%Y/%m')), as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    get float_salary_month_entries_url(year_month: @origin_year_month.strftime('%Y/%m')), as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a? Array
    data.each do |entry|
      assert_not_nil entry['year_month']
      assert_not_nil entry['status']
      assert_not_nil entry['employees_count']
      assert_equal @origin_year_month.month, Time.zone.parse(entry['year_month']).month
    end
  end

  # test "should check exists" do
  #   get check_float_salary_month_entries_url(year_month: @origin_year_month), as: :json
  #   assert_response :success
  #   assert json_res['data']
  # end

  test "should get year month options" do
    get year_month_options_float_salary_month_entries_url, as: :json
    assert_response :success
    assert json_res.is_a?(Array)
  end

  test "should get approved year month options" do
    get approved_year_month_options_float_salary_month_entries_url, as: :json
    assert_response :success
  end

  test "should create float_salary_month_entry" do
    assert_difference('FloatSalaryMonthEntry.count') do
      FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
      post float_salary_month_entries_url, params: { year_month: @start_year_month }, as: :json
      assert_response 403
      FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
      post float_salary_month_entries_url, params: { year_month: @start_year_month }, as: :json
      GeneratingFloatSalaryMonthEntriesJob.perform_now(FloatSalaryMonthEntry.find_by(year_month: @start_year_month))
      @start_year_month += 1.month
    end

    assert_response :success
  end

  test "should create bonus element items" do
    user100 = User.find(100)
    user100.location_id = @location.id
    user100.department_id = @department.id
    user100.update!(empoid: 'test_empoid')
    user100.chinese_name = 'test_chinese_name'
    user100.save!

    user101 = User.find(101)
    user101.location_id = @location.id
    user101.department_id = @department2.id
    user101.save!

    user102 = User.find(102)
    user102.location_id = @location.id
    user102.department_id = @department.id
    user102.save!

    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    post bonus_element_items_float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    post bonus_element_items_float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response :success
    assert BonusElementItem.where(float_salary_month_entry_id: @float_salary_month_entry.id, user_id: @user100.id).exists?
    assert json_res['success']
    file = Rack::Test::UploadedFile.new('test/models/import_item_2.xlsx', 'application/xlsx')
    post import_bonus_element_items_float_salary_month_entry_url(@float_salary_month_entry), { file: file }, as: :json
    assert_response :success
  end

  test "should show float_salary_month_entry" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    get float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    get float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response :success
  end

  test "should show locations_with_departments" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    get locations_with_departments_float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    get locations_with_departments_float_salary_month_entry_url(@float_salary_month_entry), as: :json
    assert_response :success
  end

  test "should update float_salary_month_entry" do
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
    patch float_salary_month_entry_url(@float_salary_month_entry), params: { status: 'approved' }, as: :json
    assert_response 403
    FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
    patch float_salary_month_entry_url(@float_salary_month_entry), params: { status: 'approved' }, as: :json
    assert_response :success
    @float_salary_month_entry.reload
    assert_equal @float_salary_month_entry.status, 'approved'
  end

  test "should destroy float_salary_month_entry" do
    assert_difference('FloatSalaryMonthEntry.count', -1) do
      FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@another_user)
      delete float_salary_month_entry_url(@float_salary_month_entry), as: :json
      assert_response 403
      FloatSalaryMonthEntriesController.any_instance.stubs(:current_user).returns(@current_user)
      delete float_salary_month_entry_url(@float_salary_month_entry), as: :json
    end

    assert_response :success
  end
end
