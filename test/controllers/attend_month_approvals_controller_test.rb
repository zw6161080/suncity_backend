# coding: utf-8
require "test_helper"

class AttendMonthApprovalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.all.each { |u| u.destroy }
    profile = create_profile
    @user = profile.user
    @location = create(:location, chinese_name: '银河')
    @department = create(:department, chinese_name: '行政及人力資源部')
    @position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = @location.id
    @user.department_id = @department.id
    @user.position_id = @position.id
    @user.save
    @attend_month_approval = create(:attend_month_approval, month: '2017/01')
    @attend = create(:attend, user_id: @user.id, attend_date: '2017/01/15')
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    @user.add_role(admin_role)
    AttendMonthApprovalsController.any_instance.stubs(:authorize).returns(true)
    AttendMonthApprovalsController.any_instance.stubs(:current_user).returns(@user)
  end

  def test_index
    get attend_month_approvals_url
    assert_response :success
    assert_equal json_res['data'].count, 1
    assert_equal json_res['data'].first['id'], @attend_month_approval.id
  end

  def test_create
    params = {
        month: '2017/02'
    }
    assert_difference('AttendMonthApproval.count') do
      post attend_month_approvals_url, params: params, as: :json
    end
    assert_response :success
    assert_equal json_res['data'], AttendMonthApproval.last.id
    assert_equal AttendMonthApproval.last.status, 'not_approval'

    params = {
        month: '2017/22'
    }
    assert_difference('AttendMonthApproval.count') do
      post attend_month_approvals_url, params: params, as: :json
    end
    assert_response 422
    assert_equal json_res['data'][0]['message'], '日期不规范'

    params = {

    }
    assert_difference('AttendMonthApproval.count') do
      post attend_month_approvals_url, params: params, as: :json
    end
    assert_response 422
    assert_equal json_res['data'][0]['message'], '参数不完整'
  end

  def test_approval
    patch approval_attend_month_approval_url(@attend_month_approval)
    assert_response :success
    assert_equal @attend_month_approval.status, 0
    assert_equal @attend_month_approval.approval_time, Time.zone.now.to_datetime
  end

  def test_patch_approval_time
    patch patch_approval_time_attend_month_approvals_url
    assert_response :success
    assert_equal @attend_month_approval.approval_time, @attend_month_approval.updated_at.to_datetime
  end

  def test_is_apply_record_compensate
    params = {
        year: '2017',
        month: '01'
    }
    get is_apply_record_compensate_attend_month_approvals_url, params: params
    assert_response :success
    assert_equal json_res.is_compensate, false
  end
end
