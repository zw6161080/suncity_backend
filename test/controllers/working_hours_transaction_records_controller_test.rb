# coding: utf-8
require "test_helper"

class WorkingHoursTransactionRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile_a = create_profile
    @user_a = profile_a.user
    profile_b = create_profile
    @user_b = profile_b.user
    location = create(:location, chinese_name: '银河')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '網絡及系統副總監')
    @user_a.location_id = location.id
    @user_a.department_id = department.id
    @user_a.position_id = position.id
    @user_a.save
    @user_b.location_id = location.id
    @user_b.department_id = department.id
    @user_b.position_id = position.id
    @user_b.save
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :WorkingHoursTransactionRecord, :macau)
    @user_a.add_role(admin_role)
    WorkingHoursTransactionRecordsController.any_instance.stubs(:current_user).returns(@user_a)
    AttendsController.any_instance.stubs(:current_user).returns(@user_a)

  end

  test "should get index" do
    create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id, apply_type: 'borrow_hours', can_be_return: false)

    params0 = {
        can_be_return: false,
        apply_type: 'borrow_hours'
    }
    get '/working_hours_transaction_records', params: params0
    assert_response :success

    params = {
      region: 'macau'
    }

    get '/working_hours_transaction_records', params: params
    assert_response :success

    params_2 = {
      location_id: 0,
    }

    get '/working_hours_transaction_records', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    params_3 = {
      user_ids: [@user_a.id],
    }

    get '/working_hours_transaction_records', params: params_3
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    working_hours_transaction_record = create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok
  end

  test "create & update" do
    params = {
      region: 'macau',
      is_compensate: true,
      user_a_id: @user_a.id,
      user_b_id: @user_b.id,
      apply_type: 0,
      apply_date: '2017/01/01',
      start_time: '10:00:00',
      end_time: '11:00:00',
      hours_count: 1,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user_a.id,
    }

    post '/working_hours_transaction_records', params: params, as: :json
    assert_response :ok

    params = {
        region: 'macau',
        is_compensate: true,
        #user_a_id: @user_a.id,
        user_b_id: @user_b.id,
        apply_type: 0,
        apply_date: '2017/01/01',
        start_time: '10:00:00',
        end_time: '11:00:00',
        hours_count: 1,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user_a.id,
    }

    post '/working_hours_transaction_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    params = {
        region: 'macau',
        is_compensate: true,
        user_a_id: @user_a.id,
        user_b_id: @user_a.id,
        apply_type: 0,
        apply_date: '2017/01/01',
        start_time: '10:00:00',
        end_time: '11:00:00',
        hours_count: 1,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user_a.id,
    }

    post '/working_hours_transaction_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '甲方乙方员工不能相同'

    get '/working_hours_transaction_records'
    assert_response :success


    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    nr = json_res['data'].first
    get "/working_hours_transaction_records/#{nr['id']}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['working_hours_transaction_record_histories'].count

    update_params = {
      region: 'macau',
      is_compensate: true,
      user_a_id: @user_a.id,
      user_b_id: @user_b.id,
      apply_type: 0,
      apply_date: '2017/01/02',
      start_time: '10:00:00',
      end_time: '12:00:00',
      hours_count: 2,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user_a.id,
    }

    patch "/working_hours_transaction_records/#{nr['id']}", params: update_params, as: :json
    assert_response :ok

    get "/working_hours_transaction_records/#{nr['id']}", as: :json
    assert_response :ok
    assert_equal 2, json_res['data']['working_hours_transaction_record_histories'].count
  end

  test "delete working_hours_transaction_record" do
    working_hours_transaction_record = create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    delete "/working_hours_transaction_records/#{working_hours_transaction_record.id}"
    assert_response :ok

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok

    assert_equal true, json_res['data']['is_deleted']
  end

  test "should get histories" do
    working_hours_transaction_record = create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}/histories", as: :json
    assert_response :ok
  end

  test "add approval & remove approval" do
    working_hours_transaction_record = create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id)
    params = {
      approval_item: {
        user_id: @user_a.id,
        date: '2017/01/10',
        comment: 'test comment',
      }
    }

    post "/working_hours_transaction_records/#{working_hours_transaction_record.id}/add_approval", params: params, as: :json_
    assert_response :ok

    params = {
        approval_item: {
            #user_id: @user_a.id,
            date: '2017/01/10',
            comment: 'test comment',
        }
    }

    post "/working_hours_transaction_records/#{working_hours_transaction_record.id}/add_approval", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['approval_items'].count

    app = json_res['data']['approval_items'].first

    delete "/working_hours_transaction_records/#{working_hours_transaction_record.id}/destroy_approval/#{app['id']}"

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok

    assert_equal 0, json_res['data']['approval_items'].count
  end

  test "add attach & remove attach" do
    working_hours_transaction_record = create(:working_hours_transaction_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    params = {
      attach_item: {
        file_name: '1.jpg',
        comment: 'test comment 1',
        attachment_id: 1,
        creator_id: @user_a.id
      }
    }

    post "/working_hours_transaction_records/#{working_hours_transaction_record.id}/add_attach", params: params, as: :json_
    assert_response :ok

    params = {
        attach_item: {
            #file_name: '1.jpg',
            comment: 'test comment 1',
            attachment_id: 1,
            creator_id: @user_a.id
        }
    }

    post "/working_hours_transaction_records/#{working_hours_transaction_record.id}/add_attach", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['attend_attachments'].count

    att = json_res['data']['attend_attachments'].first

    delete "/working_hours_transaction_records/#{working_hours_transaction_record.id}/destroy_attach/#{att['id']}"

    get "/working_hours_transaction_records/#{working_hours_transaction_record.id}", as: :json
    assert_response :ok


    assert_equal 0, json_res['data']['attend_attachments'].count
  end

  test "get options" do
    get '/working_hours_transaction_records/options'
    assert_response :ok
    assert_equal 2, json_res['data']['apply_types'].count
  end
end
