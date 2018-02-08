require "test_helper"

class ResignationRecordTest < ActiveSupport::TestCase
  test 'create resignation_record' do
    SalaryColumn.generate
    OccupationTaxSetting.load_predefined
    User.destroy_all
    test_user =  create_test_user
    create(:location, id: test_user.location_id)
    create(:position, id: test_user.position_id)
    create(:department, id: test_user.department_id)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: test_user.location_id,
      position_id: test_user.position_id,
      department_id: test_user.department_id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    params = {
      welfare_begin: Time.zone.now.beginning_of_year,
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
      user_id: test_user.id
    }
    @welfare_record = WelfareRecord.create(params)

    params = {
      resigned_date: Time.zone.now,
      user_id: test_user.id,
      resigned_reason: 'resignation',
      reason_for_resignation: 'job_description',
      employment_status: 'informal_employees',
      department_id: test_user.department_id,
      position_id: test_user.position_id,
      notice_period_compensation: true,
      compensation_year: true,
      notice_date: Time.zone.now.strftime('%Y/%m/%d')

    }
    test_ca = ResignationRecord.create(params)
    assert_equal Time.zone.now.strftime('%Y/%m/%d'), User.last.profile.data['position_information']['field_values']['resigned_date']
    assert_equal SalaryValue.all.count, SalaryColumn.count
    assert_equal test_ca.reload.status, 'being_valid'
    assert_equal test_ca.reload.time_arrive, 'arrived'
    test_ca.update(resigned_date:  (Time.zone.now + 1.day).strftime('%Y/%m/%d'))
    assert_equal (Time.zone.now + 1.day).strftime('%Y/%m/%d'), User.last.profile.data['position_information']['field_values']['resigned_date']

    ResignationRecord.update_records
  end

  private
  def resignation_record
    @resignation_record ||= ResignationRecord.new
  end

  def test_valid
    assert resignation_record.valid?
  end
end
