require 'test_helper'

class SpecialScheduleRemarksControllerTest < ActionDispatch::IntegrationTest

  setup do
    @location = create(:location, chinese_name: '测试场馆A')
    @department = create(:department, chinese_name: '测试部门A')
    @position = create(:position, chinese_name: '测试职位A')
    @profile = create_profile
    @user = create(:user,
                     chinese_name: 'Chia',
                     location_id: @location.id,
                     department_id: @department.id,
                     position_id: @position.id)
    @ssremark = create(:special_schedule_remark,
                       user_id: @user.id,
                       content: '测试文本',
                       date_begin: Time.zone.parse('2017/11/28'),
                       date_end: Time.zone.parse('2017/11/30'))
  end

  def test_index_by_user
    get index_by_user_special_schedule_remarks_url, params: { user_id: @user.id }
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_index
    get special_schedule_remarks_url, as: :json
    assert_response :success
    assert_equal SpecialScheduleRemark.first.user.position.id , @user.position_id
    assert_equal SpecialScheduleRemark.first.user.department.id , @user.department_id
    assert_equal SpecialScheduleRemark.first.date_begin.to_date, Date.parse("2017/11/28")
    assert_equal SpecialScheduleRemark.first.date_end.to_date, Date.parse("2017/11/30")
    assert_equal SpecialScheduleRemark.first.content, '测试文本'
  end

  def test_create
    create_params = {
        user_id: @user.id,
        content: '测试文本',
        date_begin: Time.zone.parse('2017/11/28'),
        date_end: Time.zone.parse('2017/11/30')
    }
    assert_difference('SpecialScheduleRemark.count') do
      post special_schedule_remarks_url, params: create_params
    end

    assert_response :success
  end

  def test_update
    update_params = {
        user_id: @user.id,
        content: '测试文本A',
        date_begin: Time.zone.parse('2017/12/28'),
        date_end: Time.zone.parse('2017/12/30')
    }
    patch special_schedule_remark_url(@ssremark), params: update_params
    assert_response :success
  end

  def test_destroy
    assert_difference('SpecialScheduleRemark.count', -1) do
      delete special_schedule_remark_url(@ssremark)
    end
    assert_response :success
  end
end
