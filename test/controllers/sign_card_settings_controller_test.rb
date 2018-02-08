require "test_helper"

class SignCardSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    SignCardSettingsController.any_instance.stubs(:current_user).returns(user)
  end


  test "should get index" do
    get '/sign_card_settings'
    assert_response :success

    assert_equal 6, json_res['data'].count
  end

  test 'should update' do
    SignCardSetting.start_init_table
    scs = SignCardSetting.first

    new_comment = 'hello comment'

    params = {
      comment: new_comment
    }

    put "/sign_card_settings/#{scs.id}", params: params, as: :json
    assert_response :success

    new_scs = SignCardSetting.find(scs.id)
    assert_equal new_comment, new_scs['comment']
  end
end
