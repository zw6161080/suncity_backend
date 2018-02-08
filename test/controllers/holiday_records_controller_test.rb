# coding: utf-8
require "test_helper"

class HolidayRecordsControllerTest < ActionDispatch::IntegrationTest
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

    @reserved_holiday_setting = create(:reserved_holiday_setting, chinese_name: '假期A',
                                       english_name: 'Holiday A',
                                       simple_chinese_name: '假期A',
                                       date_begin: '2017/11/10',
                                       date_end: '2017/11/12',
                                       days_count: 5,
                                       creator_id: @user.id
                                      )
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    admin_role.add_permission_by_attribute(:view, :HolidayRecord, :macau)
    admin_role.add_permission_by_attribute(:view_for_surplus, :HolidayRecord, :macau)

    admin_role.add_permission_by_attribute(:view_for_approve, :HolidayRecord, :macau)

    @user.add_role(admin_role)
    HolidayRecordsController.any_instance.stubs(:current_user).returns(@user)
    AttendsController.any_instance.stubs(:current_user).returns(@user)
  end

  test "should get index" do
    create(:holiday_record, user_id: @user.id, creator_id: @user.id)

    params = {
      region: 'macau'
    }

    get '/holiday_records', params: params
    assert_response :success

    params_2 = {
      location_id: 0,
    }

    get '/holiday_records', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    holiday_record = create(:holiday_record, user_id: @user.id)

    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok
  end

  test "create & update" do
    HolidayRecordsController.any_instance.stubs(:current_user).returns(@user)
    params = {
      holiday_record: {
        region: 'macau',
        user_id: @user.id,
        is_compensate: true,
        holiday_type: "reserved_holiday_#{@reserved_holiday_setting.id}",
        start_date: '2017/01/01',
        start_time: '10:00:00',
        end_date: '2017/02/02',
        end_time: '11:00:00',
        days_count: 1,
        hours_count: 1,
        year: 2017,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
      }
    }

    post '/holiday_records', params: params, as: :json
    assert_response :ok

    params = {

    }

    post '/holiday_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    params = {
        holiday_record: {
            region: 'macau',
            user_id: @user.id,
            is_compensate: true,
            holiday_type: "reserved_holiday_#{@reserved_holiday_setting.id}",
            start_date: '2017/03/01',
            start_time: '10:00:00',
            end_date: '2017/02/02',
            end_time: '11:00:00',
            days_count: 1,
            hours_count: 1,
            year: 2017,
            comment: 'comment',
            is_deleted: false,
            creator_id: @user.id,
        }
    }

    post '/holiday_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'

    params = {
        holiday_record: {
            region: 'macau',
            user_id: @user.id,
            is_compensate: true,
            holiday_type: "reserved_holiday_#{@reserved_holiday_setting.id}",
            start_date: '2017/01/01',
            start_time: '12:00:00',
            end_date: '2017/02/02',
            end_time: '11:00:00',
            days_count: 1,
            hours_count: 1,
            year: 2017,
            comment: 'comment',
            is_deleted: false,
            creator_id: @user.id,
        }
    }

    post '/holiday_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'

    attend_params = {
      attend_start_date: '2017/01/01',
      attend_end_date: '2017/01/02',
    }


    get '/attends', params: attend_params
    assert_response :success

    get '/holiday_records'
    assert_response :success

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    nr = json_res['data'].first
    get "/holiday_records/#{nr['id']}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['holiday_record_histories'].count

    update_params = {
      region: 'macau',
      user_id: @user.id,
      is_compensate: true,
      holiday_type: 'annual_leave',
      start_date: '2016/12/31',
      start_time: '10:00:00',
      end_date: '2017/02/05',
      end_time: '12:00:00',
      days_count: 2,
      hours_count: 2,
      year: 2017,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user.id,
    }

    patch "/holiday_records/#{nr['id']}", params: update_params, as: :json
    assert_response :ok

    update_params = {
        region: 'macau',
        user_id: @user.id,
        is_compensate: true,
        holiday_type: 'annual_leave',
        start_date: '2017/12/31',
        start_time: '10:00:00',
        end_date: '2017/02/05',
        end_time: '12:00:00',
        days_count: 2,
        hours_count: 2,
        year: 2017,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
    }

    patch "/holiday_records/#{nr['id']}", params: update_params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'

    update_params = {
        region: 'macau',
        user_id: @user.id,
        is_compensate: true,
        holiday_type: 'annual_leave',
        start_date: '2016/12/31',
        start_time: '13:00:00',
        end_date: '2017/02/05',
        end_time: '12:00:00',
        days_count: 2,
        hours_count: 2,
        year: 2017,
        comment: 'comment',
        is_deleted: false,
        creator_id: @user.id,
    }

    patch "/holiday_records/#{nr['id']}", params: update_params, as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['message'], '时间不正确'

    get "/holiday_records/#{nr['id']}", as: :json
    assert_response :ok
    assert_equal 2, json_res['data']['holiday_record_histories'].count
  end

  test "delete holiday_record" do
    holiday_record = create(:holiday_record, user_id: @user.id)

    delete "/holiday_records/#{holiday_record.id}"
    assert_response :ok

    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok

    assert_equal true, json_res['data']['is_deleted']
  end

  test "should get histories" do
    holiday_record = create(:holiday_record, user_id: @user.id)

    get "/holiday_records/#{holiday_record.id}/histories", as: :json
    assert_response :ok
  end

  test "add approval & remove approval" do
    holiday_record = create(:holiday_record, user_id: @user.id)
    params = {
      approval_item: {
        user_id: @user.id,
        date: '2017/01/10',
        comment: 'test comment',
      }
    }

    post "/holiday_records/#{holiday_record.id}/add_approval", params: params, as: :json_
    assert_response :ok

    params = {
        approval_item: {
            user_id: @user.id,
            #date: '2017/01/10',
            comment: 'test comment',
        }
    }

    post "/holiday_records/#{holiday_record.id}/add_approval", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    params = {
        approval_item: {
            user_id: @user.id,
            date: '2017/01/10',
            #comment: 'test comment',
        }
    }

    post "/holiday_records/#{holiday_record.id}/add_approval", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'


    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['approval_items'].count

    app = json_res['data']['approval_items'].first

    delete "/holiday_records/#{holiday_record.id}/destroy_approval/#{app['id']}"

    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok

    assert_equal 0, json_res['data']['approval_items'].count
  end

  test "add attach & remove attach" do
    holiday_record = create(:holiday_record, user_id: @user.id)

    params = {
      attach_item: {
        file_name: '1.jpg',
        comment: 'test comment 1',
        attachment_id: 1,
        creator_id: @user.id
      }
    }

    post "/holiday_records/#{holiday_record.id}/add_attach", params: params, as: :json_
    assert_response :ok

    params = {
        attach_item: {
            #file_name: '1.jpg',
            comment: 'test comment 1',
            attachment_id: 1,
            creator_id: @user.id
        }
    }

    post "/holiday_records/#{holiday_record.id}/add_attach", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['attend_attachments'].count

    att = json_res['data']['attend_attachments'].first

    delete "/holiday_records/#{holiday_record.id}/destroy_attach/#{att['id']}"

    get "/holiday_records/#{holiday_record.id}", as: :json
    assert_response :ok


    assert_equal 0, json_res['data']['attend_attachments'].count
  end

  test "get options" do
    get '/holiday_records/options'
    assert_response :ok
    assert_equal 21, json_res['data']['holiday_types'].count
  end

  test "get holiday_record_approval_for_employee" do
    create(:holiday_record, user_id: @user.id, start_date: '2017/01/02', end_date: '2017/01/06', holiday_type: 'annual_leave')

    get '/holiday_records/holiday_record_approval_for_employee'
    assert_response :ok

    params = {
      holiday_start_date: '2017/01/01',
      holiday_end_date: '2017/01/10',
    }

    get '/holiday_records/holiday_record_approval_for_employee', params: params
    assert_response :ok
  end

  test "get holiday_record_approval_for_type" do
    create(:holiday_record, user_id: @user.id, start_date: '2017/01/02', end_date: '2017/01/06', holiday_type: 'annual_leave')

    get '/holiday_records/holiday_record_approval_for_type'
    assert_response :ok

    params = {
      holiday_start_date: '2017/01/01',
      holiday_end_date: '2017/01/10',
    }

    get '/holiday_records/holiday_record_approval_for_type', params: params
    assert_response :ok

    params_2 = {
      holiday_start_date: '2017/01/01',
      holiday_end_date: '2017/01/10',
      holiday_types: ['annual_leave', 'birthday_leave'],
    }

    get '/holiday_records/holiday_record_approval_for_type', params: params_2
    assert_response :ok


    params_3 = {
      holiday_start_date: '2017/01/01',
      holiday_end_date: '2017/01/10',
      holiday_types: [],
    }

    get '/holiday_records/holiday_record_approval_for_type', params: params_3
    assert_response :ok

  end

  test "/holiday_surplus_query" do
    ['annual_leave',
     'birthday_leave',
     'paid_bonus_leave',
     'compensatory_leave',
     'paid_sick_leave',
     'unpaid_sick_leave',
     'unpaid_leave',
     'paid_marriage_leave',
     'unpaid_marriage_leave',
     'paid_compassionate_leave',
     'unpaid_compassionate_leave',
     'maternity_leave',
     'paid_maternity_leave',
     'unpaid_maternity_leave',
     'immediate_leave',
     'absenteeism',
     'work_injury',
     'unpaid_but_maintain_position',
     'overtime_leave',
     'pregnant_sick_leave'
    ].each do |type|

      create(:holiday_record, user_id: @user.id, holiday_type: type)

      # get '/holiday_records/holiday_surplus_query'
      # assert_response :ok

      params = {
        holiday_type: type,
        year: 2017,
      }

      get '/holiday_records/holiday_surplus_query', params: params
      assert_response :ok
    end
  end

  test "be able apply" do
    create(:holiday_record, user_id: @user.id, creator_id: @user.id, start_date: '2017/01/01', end_date: '2017/01/06')

    params = {
      user_id: @user.id,
      apply_start_date: '2017/01/03',
      apply_end_date: '2017/01/08'
    }

    get "/holiday_records/be_able_apply", params: params
    assert_response :ok

    params = {
      user_id: @user.id,
      apply_start_date: '2017/01/09',
      apply_end_date: '2017/01/19'
    }

    get "/holiday_records/be_able_apply", params: params
    assert_response :ok

    params = {
        user_id: @user.id,
        apply_start_date: '2018/01/03',
        apply_end_date: '2017/01/08'
    }

    get "/holiday_records/be_able_apply", params: params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '时间不正确'
  end
end
