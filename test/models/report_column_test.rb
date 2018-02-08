require 'test_helper'

class ReportColumnTest < ActiveSupport::TestCase
  setup do
    create_test_user(101)
    create_test_user(102)
    create_test_user(103)
  end

  test "test column options" do
    column = create(
      :report_column,
      key: 'department_chinese_name',
      chinese_name: 'chinese_name_xxx',
      english_name: 'english_name_xxx',
      simple_chinese_name: 'simple_chinese_name_xxx',
      value_type: 'select_value',
      search_type: 'screen',
      data_index: 'department_chinese_name',
      sorter: true,
      options_type: 'value',
      source_data_type: 'model',
      source_model: 'Department',
      source_model_user_association_attribute: 'user_id',
      join_attribute: 'created_at',
      source_attribute: 'id',
      option_attribute: 'id',
    )
    assert_equal column.options.to_set, Department.pluck(:id).to_set
  end
end
