# coding: utf-8
require "test_helper"

class PaidSickLeaveReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile = create_profile
    @user = profile.user
    location = create(:location, chinese_name: '银河')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = location.id
    @user.department_id = department.id
    @user.position_id = position.id
    @user.save
  end

  test "create reports & release" do
    create(:holiday_record,
           user_id: @user.id,
           holiday_type: 'paid_sick_leave',
           start_date: '2017/06/1',
           days_count: 2,
           year: 2017)

    params = {
      year: 2017,
      valid_period: '2017/03/01',
    }

    post '/paid_sick_leave_reports', params: params, as: :json
    assert_response :success
    byebug

    release_params = {
      year: 2017,
    }

    patch '/paid_sick_leave_reports/release', params: release_params, as: :json
    byebug
  end
end
