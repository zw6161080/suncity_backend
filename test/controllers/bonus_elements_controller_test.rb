require 'test_helper'

class BonusElementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bonus_element = create(:bonus_element)
    BonusElement.load_predefined
  end

  test "should get index" do
    get bonus_elements_url, as: :json
    assert_response :success
    assert json_res.count > 0
  end

  test "should create bonus_element" do
    assert_difference('BonusElement.count') do
      post bonus_elements_url, params: { bonus_element: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show bonus_element" do
    get bonus_element_url(@bonus_element), as: :json
    assert_response :success
  end

  test "should update bonus_element" do
    patch bonus_element_url(@bonus_element), params: { bonus_element: {  } }, as: :json
    assert_response 200
  end

  test "should destroy bonus_element" do
    assert_difference('BonusElement.count', -1) do
      delete bonus_element_url(@bonus_element), as: :json
    end

    assert_response 204
  end
end
