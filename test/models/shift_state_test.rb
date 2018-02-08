# coding: utf-8
# == Schema Information
#
# Table name: shift_states
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_is_shift      :boolean          default(TRUE)
#  current_working_hour  :string
#  future_is_shift       :boolean
#  future_working_hour   :string
#  future_affective_date :datetime
#

require 'test_helper'

class ShiftStateTest < ActiveSupport::TestCase
  test "test auto update（当天更新）" do
    shift_state = create(:shift_state, :affective_date_at_today)

    ShiftState.auto_update

    new_shift_state = ShiftState.find(shift_state['id'])

    assert_equal new_shift_state['current_is_shift'], shift_state['future_is_shift']
    assert_equal new_shift_state['current_working_hour'], shift_state['future_working_hour']
    assert_nil new_shift_state['future_is_shift']
    assert_nil new_shift_state['future_working_hour']
    assert_nil new_shift_state['future_affective_date']
  end

  test "test auto update（未来的不更新）" do
    shift_state = create(:shift_state, :future)

    ShiftState.auto_update

    new_shift_state = ShiftState.find(shift_state['id'])

    assert_equal new_shift_state['current_is_shift'], shift_state['current_is_shift']
    assert_equal new_shift_state['current_working_hour'], shift_state['current_working_hour']
    assert_equal new_shift_state['future_is_shift'], shift_state['future_is_shift']
    assert_equal new_shift_state['future_working_hour'], shift_state['future_working_hour']
    assert_equal new_shift_state['future_affective_date'], shift_state['future_affective_date']
  end

  test "test auto update（更新以前未更新的）" do
    shift_state = create(:shift_state, :affective_date_before_today)

    ShiftState.auto_update

    new_shift_state = ShiftState.find(shift_state['id'])

    assert_equal new_shift_state['current_is_shift'], shift_state['future_is_shift']
    assert_equal new_shift_state['current_working_hour'], shift_state['future_working_hour']
    assert_nil new_shift_state['future_is_shift']
    assert_nil new_shift_state['future_working_hour']
    assert_nil new_shift_state['future_affective_date']
  end

  test 'parse_time_string' do
    assert_equal ShiftState.parse_time_string('0900-1400'), { start_time: '09:00', end_time: '14:00'}
  end
end
