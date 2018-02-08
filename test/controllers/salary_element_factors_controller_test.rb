require 'test_helper'

class SalaryElementFactorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    SalaryElementCategory.load_predefined
    @salary_element_factor = SalaryElementFactor.first
    @salary_element = @salary_element_factor.salary_element
  end

  test "should get index" do
    get salary_element_salary_element_factors_url(@salary_element), as: :json
    assert_response :success
  end

  test "should create salary_element_factor" do
    create_params = {
      english_name: 'xxx',
      chinese_name: 'xxx',
      simple_chinese_name: 'xxx',
      key: 'xxx',
      factor_type: :fraction,
      comment: 'xxx',
    }

    assert_difference('SalaryElementFactor.count') do
      post salary_element_salary_element_factors_url(@salary_element), params: create_params, as: :json
    end

    assert_response 201
  end

  test "should show salary_element_factor" do
    get salary_element_factor_url(@salary_element_factor), as: :json
    assert_response :success
  end

  test "should update salary_element_factor" do
    factor_values = { numerator: '12.0', denominator: '10.0', value: '0.2' }
    patch salary_element_factor_url(@salary_element_factor), params: factor_values, as: :json
    assert_response 200
    @salary_element_factor.reload
    assert_equal BigDecimal.new(factor_values[:numerator]), @salary_element_factor.numerator
    assert_equal BigDecimal.new(factor_values[:denominator]), @salary_element_factor.denominator
    assert_equal BigDecimal.new(factor_values[:value]), @salary_element_factor.value
  end

  test "should batch update salary element factors" do
    numerator = '9.99'
    denominator ='10.99'
    value = '1.0'

    first_factor = SalaryElementFactor.first
    last_factor = SalaryElementFactor.last

    first_update = { id: first_factor.id, numerator: numerator, denominator: denominator, value: value }
    last_update = { id: last_factor.id, numerator: numerator, denominator: denominator, value: value }
    patch batch_update_salary_element_factors_url,  params: { updates: [first_update, last_update] }, as: :json
    assert_response :success

    expect = {
      numerator: BigDecimal.new(numerator),
      denominator: BigDecimal.new(denominator),
      value: BigDecimal.new(value)
    }
    first_factor.reload
    last_factor.reload
    [:numerator, :denominator, :value].each do |pname|
      assert_equal expect[pname], first_factor[pname]
      assert_equal expect[pname], last_factor[pname]
    end
  end

  test "should destroy salary_element_factor" do
    assert_difference('SalaryElementFactor.count', -1) do
      delete salary_element_factor_url(@salary_element_factor), as: :json
    end

    assert_response 204
  end
end
