require 'test_helper'

class DismissionSalaryItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(100)
    create_test_user(101)

    @current_user = User.find(100)
    @dimission = create(
      :dimission,
      user_id: 100,
      apply_date: '2001/01/01',
      inform_date: '2001/02/01',
      last_work_date: '2003/03/01',
      dimission_type: 'termination',
      career_history_dimission_reason: 'xxx',
      creator_id: 101,
      remaining_annual_holidays: nil,
    )

    create(
      :dimission,
      user_id: 101,
      apply_date: '2001/01/01',
      inform_date: '2001/02/01',
      last_work_date: '2003/03/01',
      dimission_type: 'resignation',
      career_history_dimission_reason: 'xxx',
      creator_id: 100
    )
  end

  test "should get index" do
    get dismission_salary_items_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a?(Array)
    assert data.count > 0
    assert data.all? do |row|
      DismissionSalaryItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should export xlsx" do
    get "#{social_security_fund_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    get columns_dismission_salary_items_url, as: :json
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
    get options_dismission_salary_items_url, as: :json
    assert_response :success
  end

  test "should approve dismission salary item" do
    item = DismissionSalaryItem.first
    patch approve_dismission_salary_item_url(item)
    assert_response :success
  end

  test "should query data" do
    queries = {
      employee_id: @current_user.empoid,
      dimission_type: 'termination',
    }
    get dismission_salary_items_url(**queries), as: :json
    assert_response :success
    data = json_res['data']
    assert data.is_a?(Array)
    assert_equal 1, data.count
    assert data.all? do |row|
      DismissionSalaryItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end
end
