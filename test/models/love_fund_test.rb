require 'test_helper'

class LoveFundTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'auto-update' do
    @test_profile = create_profile
    create(:love_fund, profile_id: @test_profile.id , user_id: @test_profile.user_id, participate: 'not_participated', to_status: 'participated_in_the_future', participate_date: Time.zone.now, operator_id: @test_profile.user_id)
    schedule = Whenever::Test::Schedule.new(file: 'config/schedule.rb')
    assert_difference('LoveFundRecord.count') do
      instance_eval schedule.jobs[:runner][9][:task]
    end
  end


  test 'create' do
    test_user1  = create_test_user
    LoveFund.create_with_params(test_user1,  Time.zone.now, 'participated_in_the_future', test_user1.id)
    assert_equal LoveFund.first.to_status, 'participated_in_the_future'
    assert_equal LoveFund.first.participate_date.to_s.to_date, Time.zone.now.to_s.to_date
    assert_equal LoveFundRecord.first.user_id, test_user1.id
    assert_equal LoveFundRecord.first.participate, true
    assert_equal LoveFundRecord.first.participate_end, nil

    test_user2  = create_test_user
    LoveFund.create_with_params(test_user2,  Time.zone.now + 1.day, 'participated_in_the_future', test_user2.id)
    assert_equal !!LoveFund.where(user_id: test_user2.id).first.is_participate?, false
    assert_equal LoveFund.count, 2
    assert_equal LoveFundRecord.count, 1

    LoveFund.create_with_params(test_user1,  Time.zone.now, 'participated_in_the_future', test_user1.id)
    assert_equal LoveFund.count, 3
    assert_equal LoveFundRecord.count, 2
    assert_equal LoveFundRecord.where(user_id: test_user1.id).order(created_at: :desc).second.participate_end.to_s.to_date, Time.zone.now.to_s.to_date
  end
end
