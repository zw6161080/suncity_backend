require 'test_helper'

class Roster::RosteringControllerTest < ActionDispatch::IntegrationTest
  test '开始排班接口' do
    roster = create(:roster)
    department = roster.department
    position = create(:position)
    department.positions << position

    create(:shift, roster_id: roster.id, chinese_name: '早班', english_name: 'am', start_time: '06:00', end_time: '12:00')
    create(:shift, roster_id: roster.id, chinese_name: '中班', english_name: 'pm', start_time: '12:00', end_time: '18:00')
    create(:shift, roster_id: roster.id, chinese_name: '晚班', english_name: 'night', start_time: '18:00', end_time: '24:00')

    10.times do
      user = create(:user, position_id: position.id)
      department.employees << user
    end

    post "/rosters/#{roster.id}/rostering"
    assert_response :ok

    roster.reload
    assert roster.rostered?
    assert_equal department.employees.count * (roster.availability.to_a.count), roster.items.count

    #重新排班
    byebug
    post "/rosters/#{roster.id}/rostering"
    assert_response :ok

    roster.reload
    assert roster.rostered?
    assert_equal department.employees.count * (roster.availability.to_a.count), roster.items.count
  end
end
