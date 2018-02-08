# coding: utf-8
require "test_helper"

class SignCardRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
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
    admin_role.add_permission_by_attribute(:view, :SignCardRecord, :macau)
    @user.add_role(admin_role)
    SignCardRecordsController.any_instance.stubs(:current_user).returns(@user)
    @sign_card_setting = create(:sign_card_setting, english_name: 'Others')
    @sign_card_reason = create(:sign_card_reason, sign_card_setting_id: @sign_card_setting.id)
  end

  test "should get index" do
    create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id, creator_id: @user.id)

    params = {
      region: 'macau'
    }

    get '/sign_card_records', params: params
    assert_response :success

    params_2 = {
      location_id: 0,
    }

    get '/sign_card_records', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']


    get '/sign_card_records/export_xlsx'
    assert_response :success
  end

  test "should get show" do
    sign_card_record = create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id)

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok
  end

  test "create & update" do
    params = {
      new_sign_card_records: [
        {
          region: 'macau',
          user_id: @user.id,
          is_compensate: true,
          is_get_to_work: true,
          sign_card_date: '2017/01/01',
          sign_card_time: '10:00:00',
          sign_card_setting_id: @sign_card_setting.id,
          sign_card_reason_id: @sign_card_reason.id,
          comment: 'comment',
          is_deleted: false,
          creator_id: @user.id,
        },

        {
          region: 'macau',
          user_id: @user.id,
          is_compensate: false,
          is_get_to_work: false,
          sign_card_date: '2017/01/01',
          sign_card_time: '18:00:00',
          sign_card_setting_id: @sign_card_setting.id,
          sign_card_reason_id: @sign_card_reason.id,
          comment: 'comment',
          is_deleted: false,
          creator_id: @user.id,
        },
      ]
    }

    post '/sign_card_records', params: params, as: :json
    assert_response :ok

    params = {
        new_sign_card_records: [
            {
                region: 'macau',
                user_id: @user.id,
                #is_compensate: true,
                is_get_to_work: true,
                sign_card_date: '2017/01/01',
                sign_card_time: '10:00:00',
                sign_card_setting_id: @sign_card_setting.id,
                sign_card_reason_id: @sign_card_reason.id,
                comment: 'comment',
                is_deleted: false,
                creator_id: @user.id,
            },

            {
                region: 'macau',
                user_id: @user.id,
                is_compensate: false,
                is_get_to_work: false,
                sign_card_date: '2017/01/01',
                sign_card_time: '18:00:00',
                sign_card_setting_id: @sign_card_setting.id,
                sign_card_reason_id: @sign_card_reason.id,
                comment: 'comment',
                is_deleted: false,
                creator_id: @user.id,
            },
        ]
    }

    post '/sign_card_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get '/sign_card_records'
    assert_response :success


    assert_equal 2, json_res['data'].count
    assert_equal 2, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    scr = json_res['data'].first
    get "/sign_card_records/#{scr['id']}", as: :json
    assert_response :ok
    assert_equal 1, json_res['data']['sign_card_record_histories'].count

    update_params = {
      is_compensate: false,
      is_get_to_work: false,
      sign_card_date: '2017/02/01',
      sign_card_time: '18:00:00',
      sign_card_setting_id: @sign_card_setting.id,
      sign_card_reason_id: @sign_card_reason.id,
      comment: 'comment',
      is_deleted: false,
      creator_id: @user.id,
    }

    patch "/sign_card_records/#{scr['id']}", params: update_params, as: :json
    assert_response :ok

    get "/sign_card_records/#{scr['id']}", as: :json
    assert_response :ok
    assert_equal 2, json_res['data']['sign_card_record_histories'].count

  end

  test "delete sign_card_record" do
    sign_card_record = create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id)

    delete "/sign_card_records/#{sign_card_record.id}"
    assert_response :ok

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok

    assert_equal true, json_res['data']['is_deleted']
  end

  test "should get histories" do
    sign_card_record = create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id)

    get "/sign_card_records/#{sign_card_record.id}/histories", as: :json
    assert_response :ok
  end

  test "add approval & remove approval" do
    sign_card_record = create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id)
    params = {
      approval_item: {
        user_id: @user.id,
        date: '2017/01/10',
        comment: 'test comment',
      }
    }

    post "/sign_card_records/#{sign_card_record.id}/add_approval", params: params, as: :json_
    assert_response :ok

    params = {
        approval_item: {
            user_id: @user.id,
            #date: '2017/01/10',
            comment: 'test comment',
        }
    }

    post "/sign_card_records/#{sign_card_record.id}/add_approval", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['approval_items'].count

    app = json_res['data']['approval_items'].first

    delete "/sign_card_records/#{sign_card_record.id}/destroy_approval/#{app['id']}"

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok

    assert_equal 0, json_res['data']['approval_items'].count
  end

  test "add attach & remove attach" do
    sign_card_record = create(:sign_card_record, user_id: @user.id, sign_card_setting_id: @sign_card_setting.id, sign_card_reason_id: @sign_card_reason.id)

    params = {
      attach_item: {
        file_name: '1.jpg',
        comment: 'test comment 1',
        attachment_id: 1,
        creator_id: @user.id
      }
    }

    post "/sign_card_records/#{sign_card_record.id}/add_attach", params: params, as: :json_
    assert_response :ok

    params = {
        attach_item: {
            file_name: '1.jpg',
            comment: 'test comment 1',
            attachment_id: 1,
            creator_id: @user.id
        }
    }

    post "/sign_card_records/#{sign_card_record.id}/add_attach", params: params, as: :json_
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok

    assert_equal 1, json_res['data']['attend_attachments'].count

    att = json_res['data']['attend_attachments'].first

    delete "/sign_card_records/#{sign_card_record.id}/destroy_attach/#{att['id']}"

    get "/sign_card_records/#{sign_card_record.id}", as: :json
    assert_response :ok


    assert_equal 0, json_res['data']['attend_attachments'].count
  end
end
