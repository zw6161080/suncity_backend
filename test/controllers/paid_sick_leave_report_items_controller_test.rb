require "test_helper"

class PaidSickLeaveReportItemsControllerTest < ActionDispatch::IntegrationTest
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

    @paid_sick_leave_report = create(:paid_sick_leave_report, year: 2017)
    @paid_sick_leave_report_item1 = create(:paid_sick_leave_report_item, paid_sick_leave_report_id: @paid_sick_leave_report.id, user_id: @user1.id, department_id: @department.id, year: 2017)
    @paid_sick_leave_report_item2 = create(:paid_sick_leave_report_item, paid_sick_leave_report_id: @paid_sick_leave_report.id, user_id: @user2.id, department_id: @department.id, year: 2017)
    PaidSickLeaveReportItemsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_index
    get paid_sick_leave_report_items_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count, 2

    get paid_sick_leave_report_items_url({ sort_column: 'empoid', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['empoid']<json_res['data'].first['name']['chinese_name']

    get entry_waited_records_url({ user: @user1.id }), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'user', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['id']<json_res['data'].first['user']['id']

    get entry_waited_records_url({ department: @user1.department_id }), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'department', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['department_id']<json_res['data'].first['user']['department_id']

    get entry_waited_records_url({ position: @user1.position_id }), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'position', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['user']['position_id']<json_res['data'].first['user']['position_id']

  end
end
