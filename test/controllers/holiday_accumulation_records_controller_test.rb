require 'test_helper'

class HolidayAccumulationRecordsControllerTest < ActionDispatch::IntegrationTest
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
  end

  def test_index
    params = {
        query_date: '2017/10/10',
        holiday_type: 'annual_leave',
        apply_type: 'taken'
    }
    get holiday_accumulation_records_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2
  end
end
