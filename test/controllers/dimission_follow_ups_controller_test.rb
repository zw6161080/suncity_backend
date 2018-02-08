require 'test_helper'

class DimissionFollowUpsControllerTest < ActionDispatch::IntegrationTest

  setup do
    create(:department, id: 9,chinese_name: '行政及人力資源部')
    create(:position, id: 39, chinese_name: '網絡及系統副總監')
    current_user = create(:user, department_id: 9, position_id: 39)
    DimissionFollowUpsController.any_instance.stubs(:current_user).returns(current_user)
    @dimission_follow_up = create(:dimission_follow_up)
  end

  test "should get index" do
    get dimission_follow_ups_url, as: :json
    assert_response :success

    data = json_res
    assert %w(data meta state).all? { |field| data.key? field }
    assert data['data'].all? { |item|
      DimissionFollowUp.create_params.all? { |field| item.key? field }
    }
    assert %w(total_count current_page total_pages).all? { |field| data['meta'].key? field }
    assert_equal data['state'], 'success'
  end

  test "should show dimission_follow_up" do
    get dimission_follow_up_url(@dimission_follow_up), as: :json
    assert_response :success
    data = json_res['data']
    assert DimissionFollowUp.create_params.all? { |field| data.key? field }
    assert_not data['id'] == nil
  end

  test "should update dimission_follow_up" do
    follow_up = create(:dimission_follow_up)
    follow_up.dimission_id = 100

    update_params = {
      id: follow_up.id + 1,
      dimission_id: follow_up.dimission_id + 1,
      event_key: follow_up.event_key + 'test',
      handler_id: follow_up.handler_id + 1,
      return_number: follow_up.return_number + 1,
      compensation: BigDecimal.new(follow_up.compensation) + BigDecimal.new('1000.09'),
      is_confirmed: !follow_up.is_confirmed,
      is_checked: !follow_up.is_checked,
      created_at: DateTime.now,
      updated_at: DateTime.now,
    }
    patch dimission_follow_up_url(follow_up), params: { dimission_follow_up: update_params }, as: :json
    assert_response 200

    follow_up.reload

    assert %w(id dimission_id event_key handler_id created_at updated_at).all? { |field|
      follow_up[field] != update_params.with_indifferent_access[field]
    }
    assert %w(return_number compensation is_confirmed is_checked).all? { |field|
      follow_up[field] == update_params.with_indifferent_access[field]
    }
  end
end
