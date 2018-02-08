# coding: utf-8
require "test_helper"

class AttendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    profile = create_profile
    @user = profile.user
    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = @location.id
    @user.department_id = @department.id
    @user.position_id = @position.id
    @user.save
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    @user.add_role(admin_role)

    AttendsController.any_instance.stubs(:current_user).returns(@user)
  end

  test "should get index" do
    create(:attend, user_id: @user.id)

    params = {
      attend_start_date: '2017/01/09',
      attend_end_date: '2017/01/18',
    }

    user_counts = User.count

    get '/attends', params: params
    assert_response :success

    total_page = (user_counts * 10) % 20 == 0 ? (user_counts * 10) / 20 : (user_counts * 10) / 20 + 1
    assert_equal user_counts * 10, json_res['data'].count
    assert_equal user_counts * 10, json_res['meta']['total_count']
    assert_equal total_page, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']

    params_2 = {
      attend_start_date: '2017/01/09',
      attend_end_date: '2017/01/18',
      user_ids: [@user.id]
    }

    get '/attends', params: params_2
    assert_response :success

    assert_equal 10, json_res['data'].count
    assert_equal 10, json_res['meta']['total_count']
    assert_equal 1, json_res['meta']['total_page']
    assert_equal 1, json_res['meta']['current_page']
    get '/attends/export_xlsx', params: params_2
    assert_response :success

  end

  def test_index_by_current_user
    create(:attend, user_id: @user.id)

    params = {
        attend_start_date: '2017/01/09',
        attend_end_date: '2017/01/18',
    }

    get '/attends', params: params
    assert_response :success
    assert_equal json_res['data'], 1
  end

  def test_all_attends
    attend = create(:attend, user_id: @user.id)
    attend_state = create(:attend_state, attend_id: attend.id)
    get all_attends_attends_url
    assert_response :success
    assert_equal json_res['data'].count, 1
    assert_equal json_res['data'].first.id, attend.id
    assert_equal json_res['data'].first['attend_states'].id, attend_state.id
  end

end
