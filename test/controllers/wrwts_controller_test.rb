require 'test_helper'

class WrwtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    @admin_role.add_permission_by_attribute(:information, :WelfareRecord, :macau)
    @admin_role.add_permission_by_attribute(:history, :WelfareRecord, :macau)
    @current_user.add_role(@admin_role)
    @current_user.current_region = 'macau'

    @current_user_no_role = create(:user)
    @current_user_no_role.current_region = 'macau'

    WrwtsController.any_instance.stubs(:current_user).returns(@current_user)
  end
  def wrwt
    @wrwt ||= wrwts :one
  end

  def _test_index
    get wrwts_url
    assert_response :success
  end

  def test_create
    test_user = create_test_user
    assert_difference('Wrwt.count') do
      post wrwts_url, params: {
        user_id: test_user.id,
        provide_airfare: true,
        provide_accommodation: true,
        airfare_type: 'count',
        airfare_count: 1,
      }
    end
    # assert_euqal json_res['wrwt']['user_id'], test_user.id
    assert_response 201

    get wrwt_information_options_wrwts_url
    assert_response :ok
    assert_equal json_res['provide_airfare'], Config.get_all_option_from_selects(:provide_airfare)

    params = {
      user_id: test_user.id
    }
    get current_wrwt_by_user_wrwts_url, params: params
    assert_response :ok
    assert_equal json_res['wrwt']['airfare_type'], 'count'
    assert_equal json_res['wrwt']['airfare_count'], 1
    assert_equal json_res['wrwt']['user_id'], test_user.id

    params = {
      provide_airfare: false
    }
    patch wrwt_url(Wrwt.last), params: params
    assert_response :ok
    assert_equal Wrwt.last.provide_airfare, false

    params = {
      provide_airfare: true,
      airfare_type: :round,
      airfare_count: nil
    }
    patch wrwt_url(Wrwt.last), params: params
    assert_response :ok
    assert_equal Wrwt.last.provide_airfare, true

    params = {
      provide_airfare: true,
      airfare_type: :count,
      airfare_count: 8
    }

    patch wrwt_url(Wrwt.last), params: params
    assert_response :ok
    assert_equal Wrwt.last.provide_airfare, true
    assert_equal Wrwt.last.airfare_count, 8

    test_user = create_test_user
    assert_difference('Wrwt.count', 1) do
      post wrwts_url, params: {
        user_id: test_user.id,
        provide_airfare: false,
        provide_accommodation: false,
      }
    end
    # assert_euqal json_res['wrwt']['user_id'], test_user.id
    assert_response 201
    params = {
      user_id: test_user.id
    }
    get current_wrwt_by_user_wrwts_url, params: params
    assert_response :ok
    assert_equal json_res['wrwt']['airfare_type'], nil
    assert_equal json_res['wrwt']['airfare_count'], nil
  end


  def _test_show
    get wrwt_url(wrwt)
    assert_response :success
  end

  def _test_update
    patch wrwt_url(wrwt), params: { wrwt: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('Wrwt.count', -1) do
      delete wrwt_url(wrwt)
    end

    assert_response 204
  end
end
