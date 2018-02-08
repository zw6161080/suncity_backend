require 'test_helper'

class EntryWaitedRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @applicant_profile1 = create_applicant_profile
    @applicant_profile2 = create_applicant_profile
    @applicant_profile3 = create_applicant_profile
    @applicant_profile4 = create_applicant_profile


    @applicant_position1 = create(:applicant_position, applicant_profile_id: @applicant_profile1.id, status: 'entry_needed', department_id: @department.id, position_id: @position.id)
    @applicant_position2 = create(:applicant_position, applicant_profile_id: @applicant_profile2.id, status: 'entry_needed', department_id: @department.id, position_id: @position.id)
    @applicant_position3 = create(:applicant_position, applicant_profile_id: @applicant_profile3.id, status: 'entry_needed', department_id: @department.id, position_id: @position.id)
    @applicant_position4 = create(:applicant_position, applicant_profile_id: @applicant_profile4.id, status: 'first_interview_rejected', department_id: @department.id, position_id: @position.id)
  end

  def test_index
    get entry_waited_records_url, as: :json
    assert_response :success
    assert_equal json_res['data'].count, 3

    get entry_waited_records_url({ sort_column: 'empoid', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['empoid_for_create_profile']<json_res['data'].first['empoid_for_create_profile']<json_res['data'].third['empoid_for_create_profile']

    get entry_waited_records_url({ name: @applicant_profile1.chinese_name }), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'name', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['name']['chinese_name']<json_res['data'].first['name']['chinese_name']<json_res['data'].third['name']['chinese_name']

    get entry_waited_records_url({ department: @applicant_position1.department_id }), as: :json
    assert_response :success
    assert_equal 3, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'department', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['applicant_position']['department_id']<json_res['data'].first['applicant_position']['department_id']<json_res['data'].third['applicant_position']['department_id']

    get entry_waited_records_url({ position: @applicant_position1.position_id }), as: :json
    assert_response :success
    assert_equal 3, json_res['data'].count

    get entry_waited_records_url({ sort_column: 'position', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['applicant_position']['position_id']<json_res['data'].first['applicant_position']['position_id']<json_res['data'].third['applicant_position']['position_id']

    range_begin = '2012/12/01'
    range_end   = '2012/12/31'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get entry_waited_records_url( { query_date: range } )
    assert_response :success
    assert_equal json_res['data'].count, 1

    get entry_waited_records_url({ sort_column: 'date_of_employment', sort_direction: 'desc' }), as: :json
    assert_response :success
    assert json_res['data'].second['position_to_apply']['field_values']['available_on']<json_res['data'].first['position_to_apply']['field_values']['available_on']<json_res['data'].third['position_to_apply']['field_values']['available_on']

  end

end
