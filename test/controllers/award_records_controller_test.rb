require 'test_helper'

class AwardRecordsControllerTest < ActionDispatch::IntegrationTest
  def award_record
    @award_record ||= award_records :one
  end


  def test_create
    test_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :AwardRecord, :macau)
    AwardRecordsController.any_instance.stubs(:current_user).returns(test_user)
    assert_difference('AwardRecord.count') do
      post award_records_url, params: {
        user_id: test_user.id, content: 'test', award_date: Time.zone.now, comment: 'test',reason:'test'
      }
    end

    assert_response 201
    assert_equal AwardRecord.first.user_id, test_user.id
    assert_equal AwardRecord.first.year, AwardRecord.first.award_date.beginning_of_year

    get index_by_user_award_records_url(user_id: test_user.id)
    assert_response 403

    test_user.add_role(@admin_role)
    get index_by_user_award_records_url(user_id: test_user.id)
    assert_response :ok
    assert_equal json_res['award_records'].count, 1
  end

  def test_show
    test_user = create_test_user
    ar = AwardRecord.create(user_id: test_user.id, year: Time.zone.now, content: 'test', award_date: Time.zone.now, comment: 'test', creator_id: test_user.id,reason:'test')

    get award_record_url(ar.id)
    assert_response :success
  end

  def test_update
    test_user = create_test_user
    AwardRecordsController.any_instance.stubs(:current_user).returns(test_user)
    ar = AwardRecord.create(user_id: test_user.id, year: Time.zone.now, content: 'test', award_date: Time.zone.now, comment: 'test', creator_id: test_user.id,reason:'test')
    patch award_record_url(ar.id), params: {content: 'test' }
    assert_response 200
  end

  def test_destroy
    test_user = create_test_user
    ar = AwardRecord.create(user_id: test_user.id, year: Time.zone.now, content: 'test', award_date: Time.zone.now, comment: 'test', creator_id: test_user.id,reason:'test')

    assert_difference('AwardRecord.count', -1) do
      delete award_record_url(ar.id)
    end

    assert_response 204
  end
end
