require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:department, id: 100, chinese_name: 'xxx', english_name: 'xxx')
    create(:department, id: 101, chinese_name: 'xxx1', english_name: 'xxx2')
    create(:department, id: 102, chinese_name: 'xxx1', english_name: 'xxx2')

    create(:user, id: 100, empoid: '10001', department_id: 100)
    create(:user, id: 101, empoid: '10001', department_id: 101)
    create(:user, id: 102, empoid: '10001', department_id: 102)

    @report = create(:report, url_type: 'by_id')
    report_columns = [
      create(
        :report_column,
        report: @report,
        key: 'user_id',
        chinese_name: 'ID',
        english_name: 'ID',
        simple_chinese_name: 'ID',
        value_type: 'string_value',
        data_index: 'user_id_index',
        search_type: 'search',
        sorter: true,
        options_type: nil,
        source_model: 'User',
        join_attribute: nil,
        source_attribute: 'id',
        option_attribute: nil,
        options_endpoint: nil,
      ),
      create(
        :report_column,
        report: @report,
        key: 'department_chinese_name',
        chinese_name: '部門中文',
        english_name: 'Department Chinese Name',
        simple_chinese_name: '部門中文',
        value_type: 'string_value',
        data_index: 'department_chinese_name_index',
        search_type: 'screen',
        sorter: true,
        options_type: 'api',
        source_model: 'Department',
        source_model_user_association_attribute: nil,
        user_source_model_association_attribute: 'department_id',
        join_attribute: nil,
        source_attribute: 'chinese_name',
        option_attribute: 'id',
        options_endpoint: '/departments',
      ),
      create(
        :report_column,
        report: @report,
        key: 'department_english_name',
        chinese_name: '部門英文',
        english_name: 'Department English Name',
        simple_chinese_name: '部門英文',
        value_type: 'string_value',
        data_index: 'department_english_name_index',
        search_type: 'screen',
        sorter: true,
        options_type: 'api',
        source_model: 'Department',
        source_model_user_association_attribute: nil,
        user_source_model_association_attribute: 'department_id',
        join_attribute: nil,
        source_attribute: 'english_name',
        option_attribute: 'id',
        options_endpoint: '/departments',
      ),
    ]
    @report.report_columns = report_columns
    @report.save
  end

  test "should get index" do
    get reports_url, as: :json
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? { |report| report['chinese_name'].present? }
  end

  test "shoud load predefined reports" do
    Report.load_predefined
    get reports_url, as: :json
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? { |report| report['chinese_name'].present? }
  end

  # test "should create report" do
  #   assert_difference('Report.count') do
  #     post reports_url, params: { report: {  } }, as: :json
  #   end
  #   assert_response 201
  # end

  test "should show report" do
    get report_url(@report), as: :json
    assert_response :success
    assert_not_nil json_res['columns']
    department_options = json_res['columns'].find { |c| c['key'] =~ /department/ }['options']
    assert_equal Department.distinct.pluck(:id), department_options
    assert_equal Config.get('report_column_client_attributes').fetch('attributes').to_set,
                 (json_res['columns'].first.keys - ['options']).to_set
  end

  test "should show report data" do
    get rows_report_url(@report, sort_column: 'user_id', sort_direction: 'desc', page: 1), as: :json
    assert_response :success
    assert_not_nil json_res['data']
    data = json_res['data']
    assert data.all? { |item|
      item.key?('department_chinese_name_index') && item.key?('department_english_name_index')
    }
    (1...data.size).each do |i|
      assert data[i]['user_id_index'] <= data[i - 1]['user_id_index']
    end
  end

  # test "should update report" do
  #   patch report_url(@report), params: { report: {  } }, as: :json
  #   assert_response 200
  # end

  # test "should destroy report" do
  #   assert_difference('Report.count', -1) do
  #     delete report_url(@report), as: :json
  #   end
  #   assert_response 204
  # end
end
