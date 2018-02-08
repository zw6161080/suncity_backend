# coding: utf-8
# == Schema Information
#
# Table name: rosters
#
#  id                                    :integer          not null, primary key
#  department_id                         :integer
#  state                                 :string
#  region                                :string
#  shift_interval                        :jsonb
#  rest_day_amount_per_week              :jsonb
#  rest_day_interval                     :jsonb
#  in_between_rest_day_shift_type_amount :jsonb
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  snapshot_employees_count              :integer
#  location_id                           :integer
#  from                                  :date
#  to                                    :date
#  condition                             :jsonb
#

require 'test_helper'

class RosterTest < ActiveSupport::TestCase
  test '创建排班表模型' do
    location = create(:location, id: 1)
    roster = build(:roster, location_id: location.id)
    roster.save

    assert roster.unroster?
  end

  # test '排班表创建时填充生效日期' do
  #   roster = create(:roster)
  #   assert roster.availability

  #   availability = roster.availability
  #   begin_day = availability.begin
  #   end_day = availability.end

  #   roster_month = Date.new(roster.year.to_i, roster.month.to_i).beginning_of_month
  #   first_week_start_day = nil
  #   if roster_month.beginning_of_week == roster_month
  #     first_week_start_day = roster_month
  #   else
  #     first_week_start_day = roster_month.next_week
  #   end

  #   last_week_end_day = roster_month.end_of_month.end_of_week

  #   assert_equal first_week_start_day, begin_day
  #   assert_equal last_week_end_day, end_day
  # end

  test '清空申请表' do
    location = create(:location, id: 1)
    roster = create(:roster, location_id: location.id)
    roster.shift_interval = {"1" => 2, "3" => 4}
    roster.save
    roster.reload

    roster.empty_settings!
    roster.reload
    assert_nil roster.shift_interval
  end

  test '员工未填写完整状态标志' do
    department = create(:department, id: 1)
    location = create(:location, id: 1)
    3.times do
      profile = create_profile
      user = profile.user
      user.department = department
      user.location = location
      user.save
    end

    @roster = create(:roster, department_id: department.id, location_id: location.id)
    assert !@roster.shift_user_setting_complete?
    @roster.employees.each do |user|
      create(:shift_user_setting, roster_id: @roster.id, user_id: user.id)
    end
    assert @roster.shift_user_setting_complete?
  end

  test 'availability' do
    roster = create(:roster)

    assert_equal 7, roster.availability.to_a.length
    assert_equal roster.availability.first.wday, 1
    assert_equal roster.availability.last.wday, 0
  end

end
