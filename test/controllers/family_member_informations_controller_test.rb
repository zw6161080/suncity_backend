require 'test_helper'

class FamilyMemberInformationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @current_user = create(:user)
    FamilyMemberInformationsController.any_instance.stubs(:current_user).returns(current_user)
    FamilyMemberInformationsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_show
    params = {
        family_fathers_name_chinese: 'asdf'


    }
    get "/users/#{@current_user.id}/family_member_information", params: params
    assert_response :success

    profile = create_test_user.profile
    create(:family_member_information,
           user_id:profile.user.id,
           family_fathers_name_chinese: 'asdf'
    )
    get "/users/#{@current_user.id}/family_member_information"
    assert_response :success
  end

  def test_update
    params = {
        family_fathers_name_chinese: 'asdf'
    }
    patch "/users/#{@current_user.id}/family_member_information", params: params, as: :json
    assert_response :success

    profile = create_test_user.profile
    create(:family_member_information,
           user_id:profile.user.id,
           family_fathers_name_chinese: 'asdf'

    )
    params = {
        family_fathers_name_chinese: 'af'
    }
    patch "/users/#{@current_user.id}/family_member_information", params: params, as: :json
    assert_response :success
  end

end
