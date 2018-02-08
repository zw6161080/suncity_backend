require "test_helper"

class TyphoonQualifiedRecordsControllerTest < ActionDispatch::IntegrationTest
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

    @typhoon_setting1 = create(:typhoon_setting,  start_date: '2017/10/10', end_date: '2017/10/12', start_time: '10:00', end_time: '12:00' )
    @typhoon_setting2 = create(:typhoon_setting,  start_date: '2017/12/10', end_date: '2017/12/12', start_time: '12:00', end_time: '14:00' )

    @typhoon_qualified_record1 = create(:typhoon_qualified_record, typhoon_setting_id: @typhoon_setting1.id, user_id: @user1.id)
    @typhoon_qualified_record2 = create(:typhoon_qualified_record, typhoon_setting_id: @typhoon_setting1.id, user_id: @user2.id)
    @typhoon_qualified_record3 = create(:typhoon_qualified_record, typhoon_setting_id: @typhoon_setting2.id, user_id: @user1.id)
    @typhoon_qualified_record4 = create(:typhoon_qualified_record, typhoon_setting_id: @typhoon_setting2.id, user_id: @user2.id)

    TyphoonQualifiedRecordsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_index
    get typhoon_qualified_records_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count, 4

    get typhoon_qualified_records_url({ sort_column: 'empoid', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['empoid']<json_res['data'].first['user']['empoid']<json_res['data'].third['user']['empoid']<json_res['data'].fourth['user']['empoid']

    get typhoon_qualified_records_url({ name: @ser1.id }), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    get typhoon_qualified_records_url({ sort_column: 'name', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user_id']<json_res['data'].first['user_id']<json_res['data'].third['user_id']<json_res['data'].fourth['user_id']

    get typhoon_qualified_records_url({ department: @user1.department_id }), as: :json
    assert_response :success
    assert_equal 4, json_res['data'].count

    get typhoon_qualified_records_url({ sort_column: 'department', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['department_id']<json_res['data'].first['user']['department_id']<json_res['data'].third['user']['department_id']<json_res['data'].fourth['user']['department_id']

    range_begin = '2017/12/01'
    range_end   = '2017/12/31'
    get typhoon_qualified_records_url( { typhoon_start_date: range_begin, typhoon_end_date: range_end} )
    assert_response :success
    assert_equal json_res['data'].count, 2

    get typhoon_qualified_records_url({ sort_column: 'startDate', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['typhoon_setting']['start_date']<json_res['data'].first['typhoon_setting']['start_date']<json_res['data'].third['typhoon_setting']['start_date']<json_res['data'].fourth['typhoon_setting']['start_date']

    get typhoon_qualified_records_url({ sort_column: 'endDate', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['typhoon_setting']['end_date']<json_res['data'].first['typhoon_setting']['end_date']<json_res['data'].third['typhoon_setting']['end_date']<json_res['data'].fourth['typhoon_setting']['end_date']

    get typhoon_qualified_records_url({ sort_column: 'startTime', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['typhoon_setting']['start_time']<json_res['data'].first['typhoon_setting']['start_time']<json_res['data'].third['typhoon_setting']['start_time']<json_res['data'].fourth['typhoon_setting']['start_time']

    get typhoon_qualified_records_url({ sort_column: 'endTime', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['typhoon_setting']['end_time']<json_res['data'].first['typhoon_setting']['end_time']<json_res['data'].third['typhoon_setting']['end_time']<json_res['data'].fourth['typhoon_setting']['end_time']

  end
end
