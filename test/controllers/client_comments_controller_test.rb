require 'test_helper'

class ClientCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(101)
    create_test_user(102)
    create_test_user(103)
    create_test_user(104)

    create(:questionnaire_template, id:12, region: 'macau')

    create(:questionnaire, id:13, questionnaire_template_id:12, region: 'macau')

    @comment1 = create(:client_comment, id: 1001, user_id: 101, questionnaire_template_id: 12, questionnaire_id: 13, client_account: '123', client_name: '范冰冰', client_fill_in_date: '2017/01/05', client_phone: '6666666',
                       client_account_date: '2010/03/01', involving_staff: '李晨', event_time_start: '2017/01/04 08:00', event_time_end: '2017/01/04 10:00', event_place: '北京',
                       last_tracker_id: 101, last_track_date: '2017/01/06', last_track_content: '酒店热水器已修好。')

    @comment2 = create(:client_comment, id: 1002, user_id: 102, questionnaire_template_id: 12, questionnaire_id: 13, client_account: '456', client_name: '高晓松', client_fill_in_date: '2017/01/08', client_phone: '77777',
                       client_account_date: '2008/09/01', involving_staff: '晓说摄制组', event_time_start: '2017/01/08 14:00', event_time_end: '2017/01/08 16:00', event_place: '北京',
                       last_tracker_id: 104, last_track_date: '2017/01/10', last_track_content: '已为您更换视野更好的拍摄地点。')

    @comment3 = create(:client_comment, id: 1003, user_id: 103, questionnaire_template_id: 12, questionnaire_id: 13, client_account: '789', client_name: 'AngelaBaby', client_fill_in_date: '2017/03/15', client_phone: '888888',
                       client_account_date: '2012/02/01', involving_staff: '跑男摄制组', event_time_start: '2017/03/09 08:00', event_time_end: '2017/03/09 18:00', event_place: '上海',
                       last_tracker_id: 103, last_track_date: '2017/03/17', last_track_content: '鞋子跑掉了，没有新鞋换。')

    @comment4 = create(:client_comment, id: 1004, user_id: 103, questionnaire_template_id: 12, questionnaire_id: 13, client_account: '789', client_name: 'AngelaBaby', client_fill_in_date: '2017/03/17', client_phone: '888888',
                       client_account_date: '2012/02/01', involving_staff: '跑男摄制组', event_time_start: '2017/03/17 08:01', event_time_end: '2017/03/17 08:05', event_place: '上海',
                       last_tracker_id: nil, last_track_date: nil, last_track_content: nil)

    # @comment1
    create(:client_comment_track, id: 101, user_id: 101, content: '酒店热水器坏了。', track_date: '2017/01/05', client_comment_id: 1001)
    create(:client_comment_track, id: 102, user_id: 101, content: '酒店热水器已修好。', track_date: '2017/01/06', client_comment_id: 1001)
    # @comment2
    create(:client_comment_track, id: 103, user_id: 102, content: '拍摄房间未布景。', track_date: '2017/01/09', client_comment_id: 1002)
    create(:client_comment_track, id: 104, user_id: 104, content: '已为您更换视野更好的拍摄地点。', track_date: '2017/01/10', client_comment_id: 1002)
    # @comment3
    create(:client_comment_track, id: 105, user_id: 103, content: '鞋子跑掉了，没有新鞋换。', track_date: '2017/03/17', client_comment_id: 1003)

    ClientCommentsController.any_instance.stubs(:current_user).returns(User.find(101))
    ClientCommentsController.any_instance.stubs(:authorize).returns(true)

  end

  test "get index" do
    get client_comments_url
    assert_response :success
    assert_equal 4, json_res['data'].count

    # 用于区分：客户意见 我的客户意见
    get client_comments_url, params: { user_id: 103 }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 跟進員工姓名
    get client_comments_url, params: { employee_name: User.find(103).chinese_name }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 跟進員工編號
    get client_comments_url, params: { employee_id: User.find(101).empoid }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 跟進員工部門
    get client_comments_url, params: { department: User.find(102).department_id }
    assert_response :success
    assert_equal 4, json_res['data'].count

    # 跟進員工職位
    get client_comments_url, params: { position: User.find(101).position_id }
    assert_response :success
    assert_equal 4, json_res['data'].count

    # 客戶填寫日期
    range = { begin: '2017/01/01', end: '2017/01/10' }
    get client_comments_url, params: { client_fill_in_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/01', end: nil }
    get client_comments_url, params: { client_fill_in_date: range }
    assert_response :success
    assert_equal 4, json_res['data'].count

    range = { begin: nil, end: '2017/01/10' }
    get client_comments_url, params: { client_fill_in_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 客戶戶口
    get client_comments_url, params: { client_account: '123' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get client_comments_url, params: { client_account: '00' }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 客戶姓名
    get client_comments_url, params: { client_name: '高晓松' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 最新跟進人
    get client_comments_url, params: { last_tracker: User.find(104).english_name }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 最新跟進日期
    range = { begin: '2017/01/01', end: '2017/01/31' }
    get client_comments_url, params: { last_track_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/01', end: nil }
    get client_comments_url, params: { last_track_date: range }
    assert_response :success
    assert_equal 3, json_res['data'].count

    range = { begin: nil, end: '2017/01/31' }
    get client_comments_url, params: { last_track_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count
  end

  test "get index sorted" do
    sort_column = 'last_track_date'

    get client_comments_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get client_comments_url, params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s

    get client_comments_url, params: { sort_column: 'employee_name', sort_direction: :desc }
    assert_response :success

    get client_comments_url, params: { sort_column: 'questionnaire_template', sort_direction: :desc }
    assert_response :success


  end

  test "get columns" do
    get columns_client_comments_url
    assert_response :success
  end

  test "get options" do
    get options_client_comments_url
    assert_response :success
  end

  test "export" do
    get export_client_comments_url
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/json', response.content_type
  end

  test "create 1.0" do
    # 无跟进解决方案
    post client_comments_url, params: {
        user_id: 101,
        client_account: '999999',
        client_name: '王小二',
        client_fill_in_date: '2017/01/02',
        client_phone: '123456',
        client_account_date: '2010/01/01',
        involving_staff: '黃維他',
        event_time_start: '2017/01/01 08:00',
        event_time_end: '2017/01/01 09:00',
        event_place: '事件發生地點',
     }
    assert_response 200
    assert_equal 101, ClientComment.find(json_res['data']['id']).user_id
    assert_equal '999999', ClientComment.find(json_res['data']['id']).client_account
    assert_equal '王小二', ClientComment.find(json_res['data']['id']).client_name
    assert_equal Time.zone.parse('2017/01/02'), ClientComment.find(json_res['data']['id']).client_fill_in_date
    assert_equal '123456', ClientComment.find(json_res['data']['id']).client_phone
    assert_equal Time.zone.parse('2010/01/01'), ClientComment.find(json_res['data']['id']).client_account_date
    assert_equal '黃維他', ClientComment.find(json_res['data']['id']).involving_staff
    assert_equal Time.zone.parse('2017/01/01 08:00'), ClientComment.find(json_res['data']['id']).event_time_start
    assert_equal Time.zone.parse('2017/01/01 09:00'), ClientComment.find(json_res['data']['id']).event_time_end
    assert_equal '事件發生地點', ClientComment.find(json_res['data']['id']).event_place
    assert_nil ClientComment.find(json_res['data']['id']).last_tracker_id
    assert_nil ClientComment.find(json_res['data']['id']).last_track_date
    assert_nil ClientComment.find(json_res['data']['id']).last_track_content
  end

  test "create 2.0" do
    # 有跟进解决方案
    post client_comments_url, params:  {
        user_id: 101,
        client_account: '999999',
        client_name: '王小二',
        client_fill_in_date: '2017/01/02',
        client_phone: '123456',
        client_account_date: '2010/01/01',
        involving_staff: '黃維他',
        event_time_start: '2017/01/01 08:00',
        event_time_end: '2017/01/01 09:00',
        event_place: '事件發生地點',
        track_content: '跟进解决方案'
    }
    assert_response 200
    assert_equal 101, ClientComment.find(json_res['data']['id']).user_id
    assert_equal '999999', ClientComment.find(json_res['data']['id']).client_account
    assert_equal '王小二', ClientComment.find(json_res['data']['id']).client_name
    assert_equal Time.zone.parse('2017/01/02'), ClientComment.find(json_res['data']['id']).client_fill_in_date
    assert_equal '123456', ClientComment.find(json_res['data']['id']).client_phone
    assert_equal Time.zone.parse('2010/01/01'), ClientComment.find(json_res['data']['id']).client_account_date
    assert_equal '黃維他', ClientComment.find(json_res['data']['id']).involving_staff
    assert_equal Time.zone.parse('2017/01/01 08:00'), ClientComment.find(json_res['data']['id']).event_time_start
    assert_equal Time.zone.parse('2017/01/01 09:00'), ClientComment.find(json_res['data']['id']).event_time_end
    assert_equal '事件發生地點', ClientComment.find(json_res['data']['id']).event_place
    assert_equal 101, ClientComment.find(json_res['data']['id']).last_tracker_id
    assert_not_nil ClientComment.find(json_res['data']['id']).last_track_date
    assert_equal '跟进解决方案', ClientComment.find(json_res['data']['id']).last_track_content
    # 跟进
    track = ClientCommentTrack.where(client_comment_id: json_res['data']['id']).first
    assert_equal '跟进解决方案', track.content
    assert_equal 101, track.user_id
    assert_not_nil track.track_date
    assert_equal track.track_date, ClientComment.find(json_res['data']['id']).last_track_date
    assert_equal json_res['data']['id'], track.client_comment_id
  end

  test "show 1.0" do
    get client_comment_url(@comment2.id)
    assert_response 200
    assert_not_empty json_res['data']['query']
    assert_equal 2, json_res['data']['tracks'].count
  end

  test "show 2.0" do
    get client_comment_url(@comment4.id)
    assert_response 200
    assert_not_empty json_res['data']['query']
    assert_equal [], json_res['data']['tracks']
    assert_equal 0, json_res['data']['tracks'].count
  end

  test "update" do
    patch client_comment_url(@comment1.id), params:  {
        client_account: '123456789',
        client_name: '范冰冰女王',
        client_fill_in_date: '2017/01/04',
        client_phone: '1111111111',
        client_account_date: '2009/03/01',
        involving_staff: '你我他',
        event_time_start: '2017/01/04 16:00',
        event_time_end: '2017/01/04 17:00',
        event_place: '海口',
        questionnaire_id: 13,
        questionnaire_template_id: 12,
    }
    assert_response 200
    assert_equal '123456789', ClientComment.find(@comment1.id).client_account
    assert_equal '范冰冰女王', ClientComment.find(@comment1.id).client_name
    assert_equal Time.zone.parse('2017/01/04'), ClientComment.find(@comment1.id).client_fill_in_date
    assert_equal '1111111111', ClientComment.find(@comment1.id).client_phone
    assert_equal Time.zone.parse('2009/03/01'), ClientComment.find(@comment1.id).client_account_date
    assert_equal '你我他', ClientComment.find(@comment1.id).involving_staff
    assert_equal Time.zone.parse('2017/01/04 16:00'), ClientComment.find(@comment1.id).event_time_start
    assert_equal Time.zone.parse('2017/01/04 17:00'), ClientComment.find(@comment1.id).event_time_end
    assert_equal '海口', ClientComment.find(@comment1.id).event_place
  end

  test "show tracker" do
    get '/client_comments/show_tracker', params: { user_id: 101 }
    assert_response :success
  end

end
