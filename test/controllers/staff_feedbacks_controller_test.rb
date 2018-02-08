# coding: utf-8
require 'test_helper'

class StaffFeedbacksControllerTest < ActionDispatch::IntegrationTest

  setup do
    create(:department, id: 8,  chinese_name: '行政及人力資源部')
    create(:position,   id: 38, chinese_name: '網絡及系統副總監')

    create(:department, id: 9,   chinese_name: '薪酬部')
    create(:position,   id: 39,  chinese_name: '薪酬HR')

    create(:user, id: 100, empoid: 1, department_id: 8, position_id: 38, chinese_name: '山姆', english_name: 'Sam')
    create(:user, id: 101, empoid: 2, department_id: 8, position_id: 38)
    create(:user, id: 102, empoid: 3, department_id: 9, position_id: 39, chinese_name: '喜洋洋', english_name: 'Alan')
    @current_user = create(:user, id: 103, empoid: 4, department_id: 9, position_id: 39)

    StaffFeedbacksController.any_instance.stubs(:current_user).returns(@current_user)
    StaffFeedbacksController.any_instance.stubs(:authorize).returns(true)
    create(:staff_feedback, id: 1, feedback_date: Time.zone.parse('2017/01/01'), feedback_title: '食堂的飯菜太難吃', feedback_content: '食堂的飯菜太難吃；食堂的飯菜量太少。', user_id: 100,
           feedback_track_status: 'staff_feedback.enum_track_status.untracked', feedback_tracker_id: nil, feedback_track_date: nil, feedback_track_content: nil)

    create(:staff_feedback, id: 2, feedback_date: Time.zone.parse('2017/01/02'), feedback_title: '食堂的飯菜太難吃', feedback_content: '食堂的飯菜太難吃；食堂的飯菜量太少。', user_id: 101,
           feedback_track_status: 'staff_feedback.enum_track_status.tracked', feedback_tracker_id: 102, feedback_track_date: Time.zone.parse('2017/01/04'), feedback_track_content: '食堂的飯菜太難吃')

    create(:staff_feedback, id: 5, feedback_date: Time.zone.parse('2017/01/09'), feedback_title: '很好吃', feedback_content: '很好吃，但是飯菜量有点少。', user_id: 103,
           feedback_track_status: 'staff_feedback.enum_track_status.tracking', feedback_tracker_id: 102, feedback_track_date: Time.zone.parse('2017/01/01'), feedback_track_content: '食堂的飯菜太難吃')
    @staff_feedback = StaffFeedback.find(5)

    create(:staff_feedback_track, id: 1, track_status: 'staff_feedback.enum_track_status.tracking', track_content: '食堂的飯菜太難吃', staff_feedback_id: 5, tracker_id: 102, created_at: Time.zone.parse('2017/01/01') )
    create(:staff_feedback_track, id: 2, track_status: 'staff_feedback.enum_track_status.tracking', track_content: '降低菜品價格了', staff_feedback_id: 2, tracker_id: 102, created_at: Time.zone.parse('2017/01/03') )
    create(:staff_feedback_track, id: 3, track_status: 'staff_feedback.enum_track_status.tracked', track_content: '食堂黃了，吃飯自己找地方去吧。', staff_feedback_id: 2, tracker_id: 102, created_at: Time.zone.parse('2017/01/04') )
  end

  test "should get index" do
    get staff_feedbacks_url
    assert_response :success
    json_res['data'].each do |record|
      assert ['untracked','tracking','tracked'].include?(record['feedback_track_status'])
    end

    # 提交日期
    range = { begin: '2017/01/01', end: '2017/01/01' }
    get staff_feedbacks_url, params: { feedback_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count

    range = { begin: '2017/01/01', end: '2017/01/03' }
    get staff_feedbacks_url, params: { feedback_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/01', end: nil }
    get staff_feedbacks_url, params: { feedback_date: range }
    assert_response :success
    assert_equal 3, json_res['data'].count

    range = { begin: nil, end: '2017/01/03' }
    get staff_feedbacks_url, params: { feedback_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 提交人姓名
    get staff_feedbacks_url, params: { employee_name: '山姆' }
    assert_response :success
    assert_equal json_res['data'].count, 1

    # 提交人員工編號
    get staff_feedbacks_url, params: { employee_no: 1 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 提交人部門
    get staff_feedbacks_url, params: { department_id: 9 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 提交人職位
    get staff_feedbacks_url, params: { position_id: 38 }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 跟進狀態
    get staff_feedbacks_url, params: { feedback_track_status: ['tracked'] }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get staff_feedbacks_url, params: { feedback_track_status: ['untracked','tracked'] }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 跟進人
    get staff_feedbacks_url, params: { feedback_tracker: ['Alan'] }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 跟進日期
    range = { begin: '2017/01/04', end: '2017/01/04' }
    get staff_feedbacks_url, params: { feedback_track_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count

    range = { begin: '2017/01/01', end: '2017/01/04' }
    get staff_feedbacks_url, params: { feedback_track_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/01', end: nil }
    get staff_feedbacks_url, params: { feedback_track_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: nil, end: '2017/01/01' }
    get staff_feedbacks_url, params: { feedback_track_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count
  end

  test "get index sorted" do
    sort_column = 'feedback_tracker'

    get staff_feedbacks_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get staff_feedbacks_url, params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test "should get index of my feedbacks" do
    get '/staff_feedbacks/index_my_feedbacks'
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 提交日期
    range = { begin: '2017/01/09', end: '2017/01/09' }
    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count

    range = { begin: '2017/02/09', end: nil }
    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_date: range }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 跟进状态
    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_track_status: ['tracking'] }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_track_status: ['untracked','tracked'] }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 跟进人
    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_tracker: ['Alan'] }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 跟进日期
    range = { begin: '2017/01/01', end: '2017/01/01' }
    get '/staff_feedbacks/index_my_feedbacks', params: { feedback_track_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count
  end

  test "should export all feedbacks" do
    get '/staff_feedbacks/export_all_feedbacks'
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/json', response.content_type
  end

  test "should create staff_feedback" do
    create_params = {
        user_id: 100,
        feedback_date: Date.today,
        feedback_title: '食堂的飯菜太難吃',
        feedback_content: '食堂的飯菜太難吃；食堂的飯菜量太少。',
        feedback_track_status: 'untracked',
    }
    post '/staff_feedbacks', params: { staff_feedback: create_params }, as: :json
    assert_response :success
    target = json_res['data']['id']
    assert_not_nil StaffFeedback.find(target).feedback_date
    assert_not_nil StaffFeedback.find(target).feedback_title
    assert_not_nil StaffFeedback.find(target).feedback_content
    assert_equal 'untracked', StaffFeedback.find(target).feedback_track_status
    assert_nil StaffFeedback.find(target).feedback_tracker_id
    assert_nil StaffFeedback.find(target).feedback_track_date
  end

  test "should update staff feedback" do
    patch staff_feedback_url(@staff_feedback.id), params: { feedback_title: '模棱两可' }, as: :json
    assert_response :success
    assert_not_equal '很好吃', StaffFeedback.find(@staff_feedback.id).feedback_title
  end

  test "fetch field options" do
    get '/staff_feedbacks/field_options'
    assert_response :success
    response_record = json_res['data']
    assert_not_nil response_record['positions']
    assert_not_nil response_record['departments']
    assert_not_nil response_record['track_statuses']
  end

end
