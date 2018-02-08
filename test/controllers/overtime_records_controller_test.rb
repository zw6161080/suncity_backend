# coding: utf-8
require "test_helper"

class OvertimeRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.all.each { |u| u.destroy }
    profile = create_profile
    @user = profile.user
    location = create(:location, chinese_name: '银河')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = location.id
    @user.department_id = department.id
    @user.position_id = position.id
    @user.save
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :OvertimeRecord, :macau)
    @user.add_role(admin_role)
    OvertimeRecordsController.any_instance.stubs(:current_user).returns(@user)
    AttendsController.any_instance.stubs(:current_user).returns(@user)

  end

  test "should get index" do
    create(:overtime_record, user_id: @user.id, creator_id: @user.id)

    params = {
      region: 'macau',
      is_deleted: true
    }
    get '/overtime_records', params: params
    assert_equal json_res['data'].count, 0

    params_1 = {
      region: 'macau',
      is_deleted: false
    }
    get '/overtime_records', params: params_1
    assert_response :success
    assert_equal json_res['data'].count, 1

    params_2 = {
      location_id: 0,
    }
    get '/overtime_records', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    OvertimeRecordsController.any_instance.stubs(:current_user).returns(create_test_user)
    get '/overtime_records/export_xlsx'
    assert_response :success
  end

  test "should get show" do
    overtime_record = create(:overtime_record, user_id: @user.id)

    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok
  end

  test "create & update" do
    params = {
      region: 'macau',
      user_id: @user.id,
      is_compensate: true,
      overtime_type: 'weekdays',
      compensate_type: 0,
      overtime_start_date: '2017/01/01',
      overtime_end_date: '2017/02/01',
      overtime_start_time: '10:00:00',
      overtime_end_time: '11:00:00',
      overtime_hours: 1,
      vehicle_department_over_time_min: 20,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user.id,
    }

    post '/overtime_records', params: params, as: :json
    assert_response :ok

    params = {
        region: 'macau',
        #user_id: @user.id,
        is_compensate: true,
        overtime_type: 'weekdays',
        compensate_type: 0,
        overtime_start_date: '2017/01/01',
        overtime_end_date: '2017/02/01',
        overtime_start_time: '10:00:00',
        overtime_end_time: '11:00:00',
        overtime_hours: 1,
        vehicle_department_over_time_min: 20,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
    }

    post '/overtime_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    params = {
        region: 'macau',
        user_id: @user.id,
        is_compensate: true,
        overtime_type: 'weekdays',
        compensate_type: 0,
        overtime_start_date: '2017/01/01',
        overtime_end_date: '2017/02/01',
        overtime_start_time: '10:00:00',
        overtime_end_time: '11:00:00',
        overtime_hours: 1,
        vehicle_department_over_time_min: 20,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
    }

    post '/overtime_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '加班结束时间错误'

    get '/overtime_records'
    assert_response :success


    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    nor = json_res['data'].first
    get "/overtime_records/#{nor['id']}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['overtime_record_histories'].count

    attend_params = {
      attend_start_date: '2017/01/01',
      attend_end_date: '2017/01/02',
    }

    get '/attends', params: attend_params
    assert_response :success

    update_params = {
      region: 'macau',
      user_id: @user.id,
      is_compensate: true,
      overtime_type: 'weekdays',
      compensate_type: 1,
      overtime_start_date: '2017/01/02',
      overtime_end_date: '2017/02/03',
      overtime_start_time: '10:00:00',
      overtime_end_time: '10:30:00',
      overtime_hours: 1,
      vehicle_department_over_time_min: 20,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user.id,
    }

    patch "/overtime_records/#{nor['id']}", params: update_params, as: :json
    assert_response :ok

    update_params = {
        region: 'macau',
        user_id: @user.id,
        is_compensate: true,
        overtime_type: 'weekdays',
        compensate_type: 1,
        overtime_start_date: '2017/01/02',
        overtime_end_date: '2017/02/03',
        overtime_start_time: '10:00:00',
        overtime_end_time: '10:30:00',
        overtime_hours: 1,
        vehicle_department_over_time_min: 20,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
    }

    patch "/overtime_records/#{nor['id']}", params: update_params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '加班结束时间错误'

    get "/overtime_records/#{nor['id']}", as: :json
    assert_response :ok
    assert_equal 2, json_res['data']['overtime_record_histories'].count
  end

  test "delete overtime_record" do
    overtime_record = create(:overtime_record, user_id: @user.id)

    delete "/overtime_records/#{overtime_record.id}"
    assert_response :ok

    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok

    assert_equal true, json_res['data']['is_deleted']
  end

  test "should get histories" do
    overtime_record = create(:overtime_record, user_id: @user.id)

    get "/overtime_records/#{overtime_record.id}/histories", as: :json
    assert_response :ok
  end

  test "add approval & remove approval" do
    overtime_record = create(:overtime_record, user_id: @user.id)
    params = {
      approval_item: {
        user_id: @user.id,
        date: '2017/01/10',
        comment: 'test comment',
      }
    }

    post "/overtime_records/#{overtime_record.id}/add_approval", params: params, as: :json_
    assert_response :ok

    params = {
        approval_item: {
            #user_id: @user.id,
            date: '2017/01/10',
            comment: 'test comment',
        }
    }

    post "/overtime_records/#{overtime_record.id}/add_approval", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['approval_items'].count

    app = json_res['data']['approval_items'].first

    delete "/overtime_records/#{overtime_record.id}/destroy_approval/#{app['id']}"

    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok

    assert_equal 0, json_res['data']['approval_items'].count
  end

  test "add attach & remove attach" do
    overtime_record = create(:overtime_record, user_id: @user.id)

    params = {
      attach_item: {
        file_name: '1.jpg',
        comment: 'test comment 1',
        attachment_id: 1,
        creator_id: @user.id
      }
    }

    post "/overtime_records/#{overtime_record.id}/add_attach", params: params, as: :json_
    assert_response :ok

    params = {
        attach_item: {
            #file_name: '1.jpg',
            comment: 'test comment 1',
            attachment_id: 1,
            creator_id: @user.id
        }
    }

    post "/overtime_records/#{overtime_record.id}/add_attach", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'


    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['attend_attachments'].count

    att = json_res['data']['attend_attachments'].first

    delete "/overtime_records/#{overtime_record.id}/destroy_attach/#{att['id']}"

    get "/overtime_records/#{overtime_record.id}", as: :json
    assert_response :ok


    assert_equal 0, json_res['data']['attend_attachments'].count
  end

  test "get options" do
    get '/overtime_records/options'
    assert_response :ok
    assert_equal 5, json_res['data']['overtime_types'].count
    assert_equal 2, json_res['data']['compensation_types'].count
  end
end
