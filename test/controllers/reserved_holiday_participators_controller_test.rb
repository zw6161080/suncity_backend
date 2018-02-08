require 'test_helper'

class ReservedHolidayParticipatorsControllerTest < ActionDispatch::IntegrationTest

  setup do
    profile1 = create_profile
    profile2 = create_profile
    profile3 = create_profile
    @user1 = profile1.user
    @user2 = profile2.user
    @user3 = profile3.user

    @setting = create(:reserved_holiday_setting,chinese_name: '假期A',
                      english_name: 'Holiday A',
                      simple_chinese_name: '假期A',
                      date_begin: '2017/01/01',
                      date_end: '2017/01/05',
                      days_count: 5,
                      creator_id: @user1.id
    )
    @participator = create(:reserved_holiday_participator,
                           user_id: @user3.id,
                           owned_days_count: 5,
                           reserved_holiday_setting_id: @setting.id)
  end

  def test_index
    get reserved_holiday_setting_reserved_holiday_participators_url(@setting), as: :json
    assert_response :success
  end

  def test_create
    assert_difference('ReservedHolidayParticipator.count', 2) do
      post reserved_holiday_setting_reserved_holiday_participators_url(@setting), params: { user_ids: [@user1.id, @user2.id] }
    end

    assert_response :success
    assert_equal ReservedHolidaySetting.find(@setting.id).member_count, 3
  end

  def test_destroy
    assert_difference('ReservedHolidayParticipator.count', -1) do
      delete reserved_holiday_participator_url(@participator)
    end
    assert_equal ReservedHolidaySetting.find(@setting.id).member_count, 0
    assert_response :success
  end

  def test_whether_user_added_reserved_holiday_participators
    post whether_user_added_reserved_holiday_setting_reserved_holiday_participators_url(@setting), params: { user_ids: [@user3.id, @user1.id] }
    assert_response :success

    assert_equal json_res['can_added'], false
  end

end
