require 'test_helper'

class GrantTypeDetailsControllerTest < ActionDispatch::IntegrationTest
  def grant_type_detail
    @grant_type_detail ||= grant_type_details :one
  end

  def test_index
    get grant_type_details_url
    assert_response :success
  end

  def test_create
    assert_difference('GrantTypeDetail.count') do
      post grant_type_details_url, params: { grant_type_detail: {  } }
    end

    assert_response 201
  end

  def test_show
    get grant_type_detail_url(grant_type_detail)
    assert_response :success
  end

  def test_update
    patch grant_type_detail_url(grant_type_detail), params: { grant_type_detail: {  } }
    assert_response 200
  end

  def test_destroy
    assert_difference('GrantTypeDetail.count', -1) do
      delete grant_type_detail_url(grant_type_detail)
    end

    assert_response 204
  end
end
