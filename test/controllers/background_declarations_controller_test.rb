require 'test_helper'

class BackgroundDeclarationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :WorkExperence, :macau)
    BackgroundDeclarationsController.any_instance.stubs(:current_user).returns(current_user)
    BackgroundDeclarationsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_show
    params = {
        have_any_relatives: false,
        relative_criminal_record: false,
        relative_business_relationship_with_suncity: false

    }
    get "/users/#{@current_user.id}/background_declaration", params: params
    assert_response :success

    profile = create_test_user.profile
    create(:background_declaration,
           user_id:profile.user.id,
           have_any_relatives: false,
           relative_criminal_record: false,
           relative_business_relationship_with_suncity: false

    )
    get "/users/#{@current_user.id}/background_declaration"
    assert_response :success
  end

  def test_update
    params = {
        have_any_relatives: true,
    }
    patch user_background_declaration_url(@current_user.id), params: params, as: :json
    assert_response :success
    byebug

    profile = create_test_user.profile
    create(:background_declaration,
           user_id:profile.user.id,
           have_any_relatives: false,
           relative_criminal_record: false,
           relative_business_relationship_with_suncity: false

    )
    params = {
        have_any_relatives: true,
    }
    patch "/users/#{@current_user.id}/background_declaration", params: params, as: :json
    assert_response :success
  end



end
