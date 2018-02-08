# coding: utf-8
require "test_helper"

class AdjustRosterRecordsControllerTest < ActionDispatch::IntegrationTest
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

    @class_setting = create(:class_setting, id: 1)
    @roster_object_a = create(:roster_object, class_setting_id: @class_setting.id, is_general_holiday: false)
    @roster_object_b = create(:roster_object, class_setting_id: nil, is_general_holiday: true)
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    admin_role.add_permission_by_attribute(:view, :AdjustRosterRecord, :macau)
    admin_role.add_permission_by_attribute(:view_for_report, :AdjustRosterRecord, :macau)
    @user_b.add_role(admin_role)
    AdjustRosterRecordsController.any_instance.stubs(:current_user).returns(@user_b)
    AttendsController.any_instance.stubs(:current_user).returns(@user_b)

  end

  test "should get index" do
    create(:adjust_roster_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    params = {
      region: 'macau'
    }

    get '/adjust_roster_records', params: params
    assert_response :success

    params_2 = {
      location_id: 0,
    }

    get '/adjust_roster_records', params: params_2
    assert_response :success

    assert_equal 0, json_res['data'].count
    assert_equal 0, json_res['meta']['total_count']
    assert_equal 0, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    params_3 = {
      user_ids: [@user_a.id]
    }

    get '/adjust_roster_records', params: params_3
    assert_response :success
    byebug

    assert_equal 1, json_res['data'].count
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
  end

  test "should get show" do
    adjust_roster_record = create(:adjust_roster_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    get "/adjust_roster_records/#{adjust_roster_record.id}", as: :json
    assert_response :ok
  end

  test "create" do
    params = {
      adjust_items: [
        {
          region: 'macau',
          user_a_id: @user_a.id,
          user_b_id: @user_b.id,
          user_a_adjust_date: '2017/01/01',
          user_b_adjust_date: '2017/01/02',
          user_a_roster_id: @roster_object_a.id,
          user_b_roster_id: @roster_object_b.id,
          apply_type: 0,
          is_director_special_approval: false,
          comment: 'comment',
          is_deleted: false,
          creator_id: @user_a.id,
        },
        {
          region: 'macau',
          user_a_id: @user_a.id,
          user_b_id: @user_b.id,
          user_a_adjust_date: '2017/02/01',
          user_b_adjust_date: '2017/02/02',
          user_a_roster_id: @roster_object_a.id,
          user_b_roster_id: @roster_object_b.id,
          apply_type: 0,
          is_director_special_approval: false,
          comment: 'comment',
          is_deleted: false,
          creator_id: @user_a.id,
        },
      ],

      approval_items: [
        {
          user_id: @user_a.id,
          date: '2017/01/10',
          comment: 'test comment',
        },

        {
          user_id: @user_b.id,
          date: '2017/01/10',
          comment: 'test comment 2',
        },
      ],

      attend_attachments: [
        {
          file_name: '1.jpg',
          comment: 'test comment 1',
          attachment_id: 1,
          creator_id: @user_a.id
        },
        {
          file_name: '2.jpg',
          comment: 'test comment 2',
          attachment_id: 2,
          creator_id: @user_b.id
        }
      ],
      creator_id: @user_a.id,
    }

    post '/adjust_roster_records', params: params, as: :json
    assert_response :ok

    params = {
        adjust_items: [
            {
                region: 'macau',
                #user_a_id: @user_a.id,
                user_b_id: @user_b.id,
                user_a_adjust_date: '2017/01/01',
                user_b_adjust_date: '2017/01/02',
                user_a_roster_id: @roster_object_a.id,
                user_b_roster_id: @roster_object_b.id,
                apply_type: 0,
                is_director_special_approval: false,
                comment: 'comment',
                is_deleted: false,
                creator_id: @user_a.id,
            },
            {
                region: 'macau',
                user_a_id: @user_a.id,
                user_b_id: @user_b.id,
                user_a_adjust_date: '2017/02/01',
                user_b_adjust_date: '2017/02/02',
                user_a_roster_id: @roster_object_a.id,
                user_b_roster_id: @roster_object_b.id,
                apply_type: 0,
                is_director_special_approval: false,
                comment: 'comment',
                is_deleted: false,
                creator_id: @user_a.id,
            },
        ],

        approval_items: [
            {
                user_id: @user_a.id,
                date: '2017/01/10',
                comment: 'test comment',
            },

            {
                user_id: @user_b.id,
                date: '2017/01/10',
                comment: 'test comment 2',
            },
        ],

        attend_attachments: [
            {
                file_name: '1.jpg',
                comment: 'test comment 1',
                attachment_id: 1,
                creator_id: @user_a.id
            },
            {
                file_name: '2.jpg',
                comment: 'test comment 2',
                attachment_id: 2,
                creator_id: @user_b.id
            }
        ],
        creator_id: @user_a.id,
    }

    post '/adjust_roster_records', params: params, as: :json
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'

    get '/adjust_roster_records'
    assert_response :success


    assert_equal 2, json_res['data'].count
    assert_equal 2, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    nr = json_res['data'].first
    get "/adjust_roster_records/#{nr['id']}", as: :json
    assert_response :ok

    assert_equal 2, json_res['data']['approval_items'].count
    assert_equal 2, json_res['data']['attend_attachments'].count
  end

  test "delete adjust_roster_record" do
    adjust_roster_record = create(:adjust_roster_record, user_a_id: @user_a.id, user_b_id: @user_b.id)

    delete "/adjust_roster_records/#{adjust_roster_record.id}"
    assert_response :ok

    get "/adjust_roster_records/#{adjust_roster_record.id}", as: :json
    assert_response :ok

    assert_equal true, json_res['data']['is_deleted']
    byebug
  end

  test "get options" do
    get '/adjust_roster_records/options'
    assert_response :ok
    assert_equal 2, json_res['data']['apply_types'].count
  end

  test "is_deleted" do
    10.times do |i|
      is_deleted = nil
      case i % 3
      when 0
        is_deleted = true
      when 1
        is_deleted = false
      when 2
        is_deleted = false
      end
      create(:adjust_roster_record,
             is_deleted: is_deleted,
             user_a_id: @user_a.id,
             user_b_id: @user_b.id
            )
    end

    params = {
      is_deleted: '',
    }

    get '/adjust_roster_records', params: params
    assert_response :success
    byebug
  end
end
