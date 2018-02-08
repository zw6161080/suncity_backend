require 'test_helper'

class StaffFeedbackTracksControllerTest < ActionDispatch::IntegrationTest

  setup do
    create(:department, id: 8,   chinese_name: '行政及人力資源部')
    create(:position,   id: 38,  chinese_name: '網絡及系統副總監')
    create(:location,   id: 368, chinese_name: '辦公室')

    create(:department, id: 9,   chinese_name: '薪酬部')
    create(:position,   id: 39,  chinese_name: '薪酬HR')
    create(:location,   id: 369, chinese_name: '信息安全')

    create(:user, id: 100, empoid: 1, location_id: 368, department_id: 8, position_id: 38, chinese_name: '山姆', english_name: 'Sam')
    create(:user, id: 101, empoid: 2, location_id: 368, department_id: 8, position_id: 38, chinese_name: '莉莉', english_name: 'Lily')
    create(:user, id: 102, empoid: 3, location_id: 369, department_id: 9, position_id: 39, chinese_name: '阿汤哥', english_name: 'Tom')
    create(:user, id: 103, empoid: 4, location_id: 369, department_id: 9, position_id: 39, chinese_name: '杰克船长', english_name: 'Captain Jack')

    create(:staff_feedback,       id:10, feedback_date: Date.today, feedback_title: 'xxx', feedback_content: 'xxx', user_id: 103)
    create(:staff_feedback,       id:20, feedback_date: Date.today, feedback_title: 'xxx', feedback_content: 'xxx', user_id: 101)

    create(:staff_feedback_track, id:1, track_status: 'staff_feedback.enum_track_status.untracked', track_content: 'xxx', staff_feedback_id:10, tracker_id:101)
    create(:staff_feedback_track, id:2, track_status: 'staff_feedback.enum_track_status.untracked', track_content: 'xxx', staff_feedback_id:10, tracker_id:102)
    create(:staff_feedback_track, id:3, track_status: 'staff_feedback.enum_track_status.untracked', track_content: 'xxx', staff_feedback_id:20, tracker_id:103)

    StaffFeedbackTracksController.any_instance.stubs(:current_user).returns(User.find(103))
    StaffFeedbackTracksController.any_instance.stubs(:authorize).returns(true)
  end

  test "should get index tracks" do
    get '/staff_feedbacks/10/staff_feedback_tracks'
    assert_response :success
  end

  test "should create staff_feedback_track" do
    create_params = {
        track_status: 'staff_feedback.enum_track_status.tracked',
        track_content: 'xxx',
        staff_feedback_id: 20,
    }
    post '/staff_feedbacks/10/staff_feedback_tracks', params: create_params, as: :json
    assert_response :success
    response_record = json_res['data']
    assert_equal response_record['track_status'], 'tracked'
    assert( { untracked: 'staff_feedback.enum_track_status.untracked',
                   tracking:  'staff_feedback.enum_track_status.tracking',
                   tracked:   'staff_feedback.enum_track_status.tracked' }.has_key?(response_record['track_status'].to_sym) )

    # 添加通知。每次HR跟进意见及投诉后，发通知给提交员工。
    user = User.find(103)
    get '/messages/unread_messages',
        params: { namespace: Message::NOTIFICATION_NAMESPACE },
        headers: { Token: user.token }
    assert_response :success
  end

end
