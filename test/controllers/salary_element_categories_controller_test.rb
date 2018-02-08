require 'test_helper'

class SalaryElementCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    SalaryElementCategory.load_predefined
  end

  test "should get index" do
    get salary_element_categories_url, as: :json
    assert_response :success
    data = json_res['salary_element_categories']
    assert_equal Config.get('salary_element_categories').count, data.count
    assert data.first['salary_elements'].count > 0
    assert_not_nil data.first['salary_elements'].first['key']
  end

  test "should reset salary element factor values" do
    patch reset_salary_element_categories_url, as: :json
    assert_response :success
  end

  # test "should create salary_element_category" do
  #   assert_difference('SalaryElementCategory.count') do
  #     post salary_element_categories_url, params: { salary_element_category: {  } }, as: :json
  #   end

  #   assert_response 201
  # end

  # test "should show salary_element_category" do
  #   get salary_element_category_url(@salary_element_category), as: :json
  #   assert_response :success
  # end

  # test "should update salary_element_category" do
  #   patch salary_element_category_url(@salary_element_category), params: { salary_element_category: {  } }, as: :json
  #   assert_response 200
  # end

  # test "should destroy salary_element_category" do
  #   assert_difference('SalaryElementCategory.count', -1) do
  #     delete salary_element_category_url(@salary_element_category), as: :json
  #   end
  #   assert_response 204
  # end
end