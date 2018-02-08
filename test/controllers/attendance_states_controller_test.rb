require 'test_helper'

class AttendanceStatesControllerTest < ActionDispatch::IntegrationTest
  test '获取考勤状态列表' do
    parent = create(:attendance_state)
    10.times do
      children = create(:attendance_state, parent_id: parent.id)
    end

    parent2 = create(:attendance_state)

    get '/attendance_states'
    assert_response :ok
    assert_equal AttendanceState.where(parent_id: nil).count, json_res['data'].length
    assert_equal 10, json_res['data'].first['children'].length
  end

  test '创建考勤状态' do
    params = {
      code: '001',
      chinese_name: '上班忘打卡',
      english_name: 'Forgot clock in',
      comment: 'some comment here',
    }

    assert_difference('AttendanceState.count', 1) do
      post '/attendance_states', params: params
      assert_response :ok
    end

    params = {
      code: '0011',
      chinese_name: '上班忘打卡了',
      english_name: 'Forgot clock in',
      comment: 'some comment here',
      parent_id: AttendanceState.first.id
    }

    assert_difference('AttendanceState.count', 1) do
      post '/attendance_states', params: params
      assert_response :ok
    end

    last_state = AttendanceState.last
    assert_equal AttendanceState.first.id, last_state.parent_id
  end

  test '修改考勤状态' do
    state = create(:attendance_state)
    patch "/attendance_states/#{state.id}", params: {
      code: '123'
    }
    assert_response :ok
    state.reload

    assert_equal '123', state.code
  end

  test '删除考勤状态' do
    state = create(:attendance_state)
    assert_difference('AttendanceState.count', -1) do
      delete "/attendance_states/#{state.id}"
    end
  end
end
