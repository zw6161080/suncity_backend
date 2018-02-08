# coding: utf-8
require "test_helper"

class HolidayRecordTest < ActiveSupport::TestCase
  setup do
    profile = create_profile
    @user = profile.user
    location = create(:location, chinese_name: '银河')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = location.id
    @user.department_id = department.id
    @user.position_id = position.id

    @user.welfare_records.create(
      change_reason: 'entry',
      welfare_begin: Date.new(2015, 6, 1),
      welfare_end: Date.new(2018, 1, 5),
      annual_leave: 15,
      sick_leave: 15,
      office_holiday: 15,
      probation: 30,
      notice_period: 15,
      over_time_salary: 'one_point_two_and_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      holiday_type: 'none_holiday',
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
    )

    @user.save
  end

  def holiday_record
    @holiday_record ||= HolidayRecord.new
  end

  def test_valid
    assert holiday_record.valid?
  end

  def test_calc_annual_leave_count_for_front
    @user.profile.data['position_information']['field_values']['date_of_employment'] = Date.new(2015, 6, 1)
    @user.profile.data['position_information']['field_values']['division_of_job'] = 'front_office'
    @user.save

    assert_equal 0, HolidayRecord.calc_annual_leave_count(@user, 2015)
    assert_equal 7, HolidayRecord.calc_annual_leave_count(@user, 2017)
    assert_equal 8, HolidayRecord.calc_annual_leave_count(@user, 2018)
    assert_equal 12, HolidayRecord.calc_annual_leave_count(@user, 2022)
    assert_equal 12, HolidayRecord.calc_annual_leave_count(@user, 2023)
  end

  def test_calc_annual_leave_count_for_back
    @user.profile.data['position_information']['field_values']['date_of_employment'] = Date.new(2016, 1, 15)
    @user.profile.data['position_information']['field_values']['division_of_job'] = 'back_office'

    @user.profile.data['position_information']['field_values']['employment_status'] = 'informal_employees'
    @user.save

    # assert_equal 0, HolidayRecord.calc_annual_leave_count(@user, 2017)
    assert_equal 14, HolidayRecord.calc_total_until_date(@user, 'annual_leave', Date.new(2017, 2, 15))

    # @user.profile.data['position_information']['field_values']['employment_status'] = 'formal_employees'
    # @user.save
    assert_equal 15, HolidayRecord.calc_annual_leave_count(@user, 2017)

    assert_equal 43, HolidayRecord.calc_surplus(@user, 'annual_leave', 2018)

    @user.welfare_records.create(
      change_reason: 'entry',
      welfare_begin: Date.new(2018, 1, 6),
      annual_leave: 25,
      sick_leave: 15,
      office_holiday: 15,
      probation: 30,
      notice_period: 30,
      over_time_salary: 'one_point_two_and_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      holiday_type: 'none_holiday',
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
    )

    assert_equal 25, HolidayRecord.calc_annual_leave_count(@user, 2018)
  end
end
