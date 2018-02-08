require 'test_helper'

class CardHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create(:user)
    CardHistoriesController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test 'card history create' do
    profile = create(:card_profile)
    post "/card_histories",params: {new_or_renew:'renew',
                                    date_to_get_card:'2117-08-01',
                                    certificate_valid_date:'2117-07-01',
                                    new_approval_valid_date:'2117-09-01',
                                    card_valid_date:'2018-09-01',
                                    card_profile_id: profile.id
    }
    assert_response :ok
    assert_equal 'renew', CardHistory.first.new_or_renew
    assert_equal 'renew', CardProfile.first.new_or_renew
    assert_equal 6, profile.card_records.count
  end

  test 'card history update' do
    card = create(:card_history)
    profile = create(:card_profile)
    card.update(card_profile_id: profile.id )
    patch "/card_histories/#{card.id}",params: {new_or_renew:'renew',
                                                date_to_get_card:'2000-08-01',
                                                certificate_valid_date:'2000-07-01',
                                                new_approval_valid_date:'2000-09-01',
                                                card_valid_date:'2000-09-01',}
    assert_response :ok
    assert_equal 'renew', CardHistory.first.new_or_renew
    assert_equal 'renew', CardProfile.first.new_or_renew
    assert_equal 6, profile.card_records.count
  end
  #
  test 'card history destroy' do
    card1 = create(:card_history)
    card2 = create(:card_history)
    profile = create(:card_profile)
    card1.update(card_profile_id: profile.id )
    card2.update(card_profile_id: profile.id )
    card2.update(card_valid_date: "2222-2-2" )

    delete "/card_histories/#{card1.id}"
    assert_response :ok
    assert_equal 1, CardHistory.count
    assert_equal 6, profile.card_records.count
  end
end


