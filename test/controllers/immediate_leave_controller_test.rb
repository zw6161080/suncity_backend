require 'test_helper'

class ImmediateLeaveControllerTest < ActionDispatch::IntegrationTest

  setup do
    create(:department, id: 9,chinese_name: '行政及人力資源部')
    create(:position, id: 39, chinese_name: '網絡及系統副總監')
    @current_user = create(:user)
    ImmediateLeaveController.any_instance.stubs(:current_user).returns(@current_user)
  end


  test "post create and get show" do
    user = create(:user, department_id: 9, position_id: 39)
    params = {
      user_id: user.id,
      comment: 'test comment',
      date: '2017/01/10',
      immediate_leave_items: [
        {
          comment: 'test comment'
        },
        {
          comment: 'test comment2'
        }
      ],
      attend_approvals: [
        {
          user_id: 4,
          date: '2017/01/10',
          comment: 'test comment',
        },
        {
          user_id: 4,
          date: '2017/01/10',
          comment: 'test comment',
        },
        {
          user_id: 4,
          date: '2017/01/10',
          comment: 'test comment',
        }
      ],
      attend_attachments: [
        {
          file_name: 'fn.jpg',
          comment: 'test comment',
          attachment_id: 2
        },
        {
          file_name: 'fn.jpg',
          comment: 'test comment',
          attachment_id: 2
        },
        {
          file_name: 'fn.jpg',
          comment: 'test comment',
          attachment_id: 2
        }
      ]

    }
    assert_difference(['ImmediateLeave.count'], 1) do
    assert_difference(['ImmediateLeaveItem.count'], 2) do
    assert_difference(['AttendApproval.count'], 3) do
    assert_difference(['AttendAttachment.count'], 3) do
      post '/immediate_leave', params: params, as: :json
      immediate_leave = ImmediateLeave.first

      assert_response :ok
      assert_equal immediate_leave.attend_attachments.pluck(:creator_id).uniq, [@current_user.id]
      assert_equal immediate_leave.status, 'approved'
      assert_equal immediate_leave.item_count, 2
    end
    end
    end
    end

    immediate_leave = ImmediateLeave.first
    get "/immediate_leave/#{immediate_leave.id}"
    assert_response :ok
    assert_equal json_res['data']['creator_id'], @current_user.id
    get '/immediate_leave'
    assert_response :ok
    get '/immediate_leave/field_options'
    assert_response :ok
  end
end
