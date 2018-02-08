require "test_helper"

class WelfareRecordTest < ActiveSupport::TestCase


  test 'create welfare_record' do
    params = {
      welfare_begin: Time.zone.now,
      change_reason: 'entry',
      annual_leave: 2,
      sick_leave: 2,
      office_holiday: 2,
      holiday_type: 'none_holiday',
      probation: 30,
      notice_period: 30,
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
      over_time_salary: 'one_point_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      user_id: test_id = create_test_user.id,
    }
    @welfare_record = WelfareRecord.create(params)
    assert test_valid
    assert_equal WelfareRecord.find(@welfare_record.id).welfare_begin.to_date.to_s, Time.zone.now.to_date.to_s
    assert_equal WelfareRecord.find(@welfare_record.id).status, 'being_valid'
    params = {
      change_reason: 'entry',
      welfare_begin: '2017/06/03',
      annual_leave: 2,
      sick_leave: 2,
      office_holiday: 2,
      holiday_type: 'none_holiday',
      probation: 30,
      notice_period: 30,
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
      over_time_salary: 'one_point_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      user_id: test_id,
    }
    wf2 = WelfareRecord.create(params)
    assert_equal WelfareRecord.where(user_id: test_id).count, 2
    assert_equal WelfareRecord.find(wf2.id).status, 'being_valid'

    WelfareRecord.find(wf2.id).update_columns(status: :to_be_valid)
    WelfareRecord.update_records
    assert_equal WelfareRecord.find(wf2.id).status, 'being_valid'
  end

  private
  def welfare_record
    @welfare_record ||= WelfareRecord.new
  end


  def test_valid
    @welfare_record.valid?
  end
end
