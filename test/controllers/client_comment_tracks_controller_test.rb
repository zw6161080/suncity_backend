require 'test_helper'

class ClientCommentTracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(101)
    create_test_user(102)

    create(:client_comment, id: 1001, user_id: 101, client_account: '123', client_name: '范冰冰', client_fill_in_date: '2017/01/05', client_phone: '6666666',
           client_account_date: '2010/03/01', involving_staff: '李晨', event_time_start: '2017/01/04 08:00', event_time_end: '2017/01/04 10:00', event_place: '北京',
           last_tracker_id: 102, last_track_date: '2017/01/07', last_track_content: '酒店热水器已修好。')

    @track1 = create(:client_comment_track, id: 51, content: '跟进内容1', user_id: 101, track_date: Time.zone.parse('2017/01/05'), client_comment_id: 1001)
    @track2 = create(:client_comment_track, id: 52, content: '跟进内容2', user_id: 102, track_date: Time.zone.parse('2017/01/06'), client_comment_id: 1001)
    @track3 = create(:client_comment_track, id: 53, content: '酒店热水器已修好。', user_id: 102, track_date: Time.zone.parse('2017/01/07'), client_comment_id: 1001)

    ClientCommentTracksController.any_instance.stubs(:current_user).returns(User.find(101))
    ClientCommentTracksController.any_instance.stubs(:authorize).returns(true)
  end

  test "create" do
    post '/client_comments/1001/client_comment_tracks', params: { client_comment_track: {
        content: '加強員工培訓'
    } }
    assert_response 200
    assert_equal '加強員工培訓', ClientCommentTrack.find(json_res['data']['id']).content
    assert_equal 101, ClientCommentTrack.find(json_res['data']['id']).user_id
    assert_not_nil ClientCommentTrack.find(json_res['data']['id']).track_date
    assert_equal 1001, ClientCommentTrack.find(json_res['data']['id']).client_comment_id
    track = ClientCommentTrack.find(json_res['data']['id'])
    comment = ClientComment.find(track.client_comment_id)
    assert_equal track.user_id, comment.last_tracker_id
    assert_equal track.track_date, comment.last_track_date
    assert_equal track.content, comment.last_track_content
  end

  test "show" do
    get "/client_comments/1001/client_comment_tracks/#{@track1.id}"
    assert_response 200
    assert_includes(json_res, 'content')
    assert_includes(json_res, 'user')
  end

  test "update" do
    patch "/client_comments/1001/client_comment_tracks/#{@track1.id}", params: { client_comment_track: { content: '加強員工服飾儀表' } }
    assert_response 200
    assert_equal '加強員工服飾儀表', ClientCommentTrack.find(@track1.id).content
    assert_equal 101, ClientCommentTrack.find(@track1.id).user_id
    assert_equal 1001, ClientCommentTrack.find(@track1.id).client_comment_id
  end

  test "destroy 1.0" do
    # 有多条跟进，删除最新一条跟进
    assert_difference('ClientCommentTrack.count', -1) do
      delete "/client_comments/1001/client_comment_tracks/#{@track3.id}"
    end
    assert_response 200
    track = ClientCommentTrack.find(@track2.id)
    comment = ClientComment.find(track.client_comment_id)
    assert_equal track.user_id, comment.last_tracker_id
    assert_equal track.track_date, comment.last_track_date
    assert_equal track.content, comment.last_track_content
  end

  test "destroy 2.0" do
    # 有多条跟进，删除旧的跟进
    assert_difference('ClientCommentTrack.count', -1) do
      delete "/client_comments/1001/client_comment_tracks/#{@track1.id}"
    end
    assert_response 200
    track = ClientCommentTrack.find(@track3.id)
    comment = ClientComment.find(track.client_comment_id)
    assert_equal track.user_id, comment.last_tracker_id
    assert_equal track.track_date, comment.last_track_date
    assert_equal track.content, comment.last_track_content
  end

  test "destroy 3.0" do
    # 有一条跟进，删除唯一跟进
    create(:client_comment, id: 1002, user_id: 102, client_account: '123', client_name: '范冰冰', client_fill_in_date: '2017/01/05', client_phone: '6666666',
           client_account_date: '2010/03/01', involving_staff: '李晨', event_time_start: '2017/01/04 08:00', event_time_end: '2017/01/04 10:00', event_place: '北京',
           last_tracker_id: 102, last_track_date: '2017/01/07', last_track_content: '礼服已准备好。')

    @track4 = create(:client_comment_track, content: '礼服已准备好。', user_id: 102, track_date: Time.zone.parse('2017/01/07'), client_comment_id: 1002)

    assert_difference('ClientCommentTrack.count', -1) do
      delete "/client_comments/1001/client_comment_tracks/#{@track4.id}"
    end
    assert_response 200
    comment = ClientComment.find(1002)
    assert_nil comment.last_tracker_id
    assert_nil comment.last_track_date
    assert_nil comment.last_track_content
  end

end
