require 'test_helper'

class ProfitConflictInformationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @current_user = create(:user)
    ProfitConflictInformationsController.any_instance.stubs(:current_user).returns(current_user)
    ProfitConflictInformationsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_show
    params = {
        have_or_no: true,
        number:'123'


    }
    get "/users/#{@current_user.id}/profit_conflict_information", params: params
    assert_response :success

    profile = create_test_user.profile
    create(:profit_conflict_information,
           user_id:profile.user.id,
           have_or_no: true,
           number:'123'
    )
    get "/users/#{@current_user.id}/profit_conflict_information"
    assert_response :success
  end

  def test_update
    params = {
        have_or_no: true,
        number:'123'
    }
    patch "/users/#{@current_user.id}/profit_conflict_information", params: params, as: :json
    assert_response :success

    profile = create_test_user.profile
    create(:profit_conflict_information,
           user_id:profile.user.id,
           have_or_no: true,
           number:'123'

    )
    params = {
        have_or_no: true,
        number:'123'
    }
    patch "/users/#{@current_user.id}/profit_conflict_information", params: params, as: :json
    assert_response :success
  end
end
