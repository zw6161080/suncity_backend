require 'test_helper'

class SalaryColumnTemplatesControllerTest < ActionDispatch::IntegrationTest
  def salary_column_template
    @salary_column_template ||= salary_column_templates :one
  end

  def test_index
    get salary_column_templates_url
    assert_response :success
  end

  def test_create
    SalaryColumn.generate
    assert_difference('SalaryColumnTemplate.count') do
      post salary_column_templates_url, params: { salary_column_template: { name: 'test', column_array: [1,2] } }
    end

    assert_equal SalaryColumnTemplate.first.name, 'test'
    assert_equal SalaryColumnTemplate.first.salary_columns.count, 2

    get salary_column_templates_url
    assert_response :success

    assert_difference('SalaryColumnTemplate.count') do
      post salary_column_templates_url, params: { salary_column_template: { name: 'test', column_array: [1,3,2,4] } }
    end
    assert_response :success
    assert_equal SalaryColumnTemplate.last.salary_columns.count, 4
    assert_equal SalaryColumnTemplate.last.original_column_order, [1,3,2,4]

    get get_default_template_salary_column_templates_url
    assert_response :success
    assert_equal json_res['salary_column_template']['id'], SalaryColumnTemplate.first.id
  end

  def test_show
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    get salary_column_template_url(salary_column_template)
    assert_response :success
    assert_equal json_res['salary_column_template']['salary_columns'].count, 2
  end

  def test_update
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    patch salary_column_template_url(salary_column_template), params: { salary_column_template: {  name: 'test2' } }
    assert_response 200
    assert_equal SalaryColumnTemplate.first.name, 'test2'
  end

  def test_destroy
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    assert_difference('SalaryColumnTemplate.count', -1) do
      delete salary_column_template_url(salary_column_template)
    end

    assert_response 200
    assert_equal SalaryColumnTemplate.count , 0
  end

  def test_set_default_template
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])

    @salary_column_template1 = SalaryColumnTemplate.create(name: 'test2')
    @salary_column_template1.salary_columns << SalaryColumn.where(id: [1,2])

    patch set_default_salary_column_template_url(id: @salary_column_template1.id)
    assert_response :ok
    assert @salary_column_template1.reload.default

  end

  def test_all_columns
    SalaryColumn.generate
    get all_columns_salary_column_templates_url
    assert_response 200
    assert_equal json_res['salary_columns'].count, 218
  end
end
