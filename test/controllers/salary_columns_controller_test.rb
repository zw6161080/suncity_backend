require 'test_helper'

class SalaryColumnsControllerTest < ActionDispatch::IntegrationTest
  def salary_column
    @salary_column ||= salary_columns :one
  end

  def test_index
    get salary_columns_url
    assert_response :success
  end

  def test_create
    assert_difference('SalaryColumn.count') do
      post salary_columns_url, params: { salary_column: {  } }
    end

    assert_response 201
  end

  def test_show
    get salary_column_url(salary_column)
    assert_response :success
  end

  def test_update
    patch salary_column_url(salary_column), params: { salary_column: {  } }
    assert_response 200
  end

  def test_destroy
    assert_difference('SalaryColumn.count', -1) do
      delete salary_column_url(salary_column)
    end

    assert_response 204
  end
end
