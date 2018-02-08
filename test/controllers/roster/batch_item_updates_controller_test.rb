require 'test_helper'

class Roster::BatchItemUpdatesControllerTest < ActionDispatch::IntegrationTest
  test '批量修改排班表排班项目' do
    roster = rostered_roster
    items = roster.items
    shifts = roster.shifts
    leaves = Leave.all

    items_need_update = items.sample(10).map do |item|
      if rand(10) % 2 == 0
        {
          id: item.id,
          shift_id: shifts.sample.id
        }
      else
        {
          id: item.id,
          leave_type: leaves.sample[:key]
        }
      end
    end

    post "/rosters/#{roster.id}/batch_item_updates", params: {
      items: items_need_update
    }, xhr: true

    assert_response :ok

  end
end
