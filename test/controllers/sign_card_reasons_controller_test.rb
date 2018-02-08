require "test_helper"

class SignCardReasonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    SignCardReasonsController.any_instance.stubs(:current_user).returns(user)
  end

  test 'should create' do
    SignCardSetting.start_init_table
    scs = SignCardSetting.first

    new_reason = 'new_reason'
    new_reason_code = 'new_reason_code'
    new_comment = 'new_comment'

    params = {
      region: 'macau',
      reason: new_reason,
      reason_code: new_reason_code,
      comment: new_comment,
    }

    assert_difference(['SignCardReason.count'], 1) do
      assert_difference(['scs.sign_card_reasons.count'], 1) do
        post "/sign_card_settings/#{scs.id}/sign_card_reasons", params: params, as: :json
        assert_response :success
      end
    end
  end

  test 'should update' do
    SignCardSetting.start_init_table
    scs = SignCardSetting.last
    scr = scs.sign_card_reasons.first
    new_reason = "new #{scr.reason}"

    params = {
      reason: new_reason,
    }

    put "/sign_card_settings/#{scs.id}/sign_card_reasons/#{scr.id}", params: params, as: :json
    assert_response :success

    assert_equal new_reason, SignCardSetting.last.sign_card_reasons.first.reason
  end

  test "should destroy" do
    SignCardSetting.start_init_table
    scs = SignCardSetting.last
    scr = scs.sign_card_reasons.last

    unless scr.be_used
      assert_difference(['SignCardReason.count'], -1) do
        assert_difference(['scs.sign_card_reasons.count'], -1) do
          delete "/sign_card_settings/#{scs.id}/sign_card_reasons/#{scr.id}"
          assert_response :success
        end
      end
    end
  end
end
