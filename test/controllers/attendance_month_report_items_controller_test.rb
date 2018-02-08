require 'test_helper'

class AttendanceMonthReportItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.destroy_all
    # create(:department, id: 100, chinese_name: 'xxx', english_name: 'xxx')
    # create(:department, id: 101, chinese_name: 'xxx1', english_name: 'xxx2')
    # create(:department, id: 102, chinese_name: 'xxx1', english_name: 'xxx2')
    # create(:position, id: 100, chinese_name: 'yyy', english_name: 'yyy')
    # @user = create(:user, id: 100, empoid: '10001', department_id: 100, position_id: 100)
    # another_user = create(:user, id: 101, empoid: '10001', department_id: 101)
    # create(:user, id: 102, empoid: '10001', department_id: 102)
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    @user = User.find(100)
    another_user = User.find(101)
    AttendanceMonthReportItemsController.any_instance.stubs(:current_user).returns(@user)
    AttendanceMonthReportItemsController.any_instance.stubs(:authorize).returns(true)

    AttendanceMonthReportItem.generate(@user, Time.zone.parse('2017/05'))
    AttendanceMonthReportItem.generate(@user, Time.zone.parse('2017/06'))
    AttendanceMonthReportItem.generate(another_user, Time.zone.parse('2017/06'))

    Report.load_predefined
  end

  test "should get index" do
    get attendance_month_report_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a?(Array)
    assert data.count > 0
    assert data.all? do |row|
      AttendanceMonthReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should export xlsx" do
    get "#{attendance_month_report_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    get columns_attendance_month_report_items_url, as: :json
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
    get options_attendance_month_report_items_url, as: :json
    assert_response :success
    AttendanceMonthReportItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should get year month options" do
    get year_month_options_attendance_month_report_items_url, as: :json
    assert_response :success
  end

  test "should query data" do
    queries = {
      employee_id: @user.empoid,
      year_month: '2017/05'
    }
    get attendance_month_report_items_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res.all? do |row|
      AttendanceMonthReportItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

end
