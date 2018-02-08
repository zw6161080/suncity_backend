require 'test_helper'

class TakenHolidayRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile1 = create_profile
    @user1 = profile1.user
    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @user1.location_id = @location.id
    @user1.department_id = @department.id
    @user1.position_id = @position.id
    @user1.save

    profile2 = create_profile
    @user2 = profile2.user
    @user2.location_id = @location.id
    @user2.department_id = @department.id
    @user2.position_id = @position.id
    @user2.save

    @attend1 = create(:attend, user_id: @user1.id)
    @holiday_record1 = create(:holiday_record, user_id: @user1.id)
    @taken_holiday_record1 = create(:taken_holiday_record, user_id: @user1.id, holiday_record_id: @holiday_record.id, attend_id: @attend.id, taken_holiday_date: '2017/10/10')

    @attend2 = create(:attend, user_id: @user2.id)
    @holiday_record2 = create(:holiday_record, user_id: @user2.id)
    @taken_holiday_record2 = create(:taken_holiday_record, user_id: @user2.id, holiday_record_id: @holiday_record.id, attend_id: @attend.id, taken_holiday_date: '2017/10/10')

  end
  def test_index
    get taken_holiday_records_url
    assert_response :success
    assert_equal json_res['data'].count, 1

    get taken_holiday_records_url({ name: @user1.chinese_name }), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

    get taken_holiday_records_url({ user_id: @user1.id }), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

  end
end
