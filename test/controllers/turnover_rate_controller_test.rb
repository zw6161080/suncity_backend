require "test_helper"

class TurnoverRateControllerTest < ActionDispatch::IntegrationTest
  setup do

  end

  def test_columns
    get columns_turnover_rate_index_url
    assert_response :success
  end

  def test_options
    get options_turnover_rate_index_url
    assert_response :success
  end

  def test_index
    user = create_profile.user
    user_a = create_profile.user
    user_b = create_profile.user
    user_c = create_profile.user
    user_d = create_profile.user
    user_e = create_profile.user
    department = create(:department)
    user.department_id = department.id
    user_a.department_id = department.id
    user_b.department_id = department.id
    user_c.department_id = department.id
    user_d.department_id = department.id
    user_e.department_id = department.id
    user.save
    user_a.save
    user_b.save
    user_c.save
    user_d.save
    user_e.save
    CareerRecordsController.any_instance.stubs(:current_user).returns(user)
    CareerRecordsController.any_instance.stubs(:authorize).returns(true)
    TurnoverRateController.any_instance.stubs(:current_user).returns(user)
    TurnoverRateController.any_instance.stubs(:authorize).returns(true)
    location = create(:location)
    location.departments << user.department
    position = create(:position)
    basic_params = {
        deployment_type: 'entry',  salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited', location_id: location.id, position_id: position.id,
        department_id: department.id, grade: position.grade, division_of_job: 'front_office', employment_status: 'informal_employees'
    }
    resignation_params = {
        resigned_reason: 'resignation', reason_for_resignation: 'job_description',
        department_id: user.department_id, position_id: user.position_id, notice_period_compensation: false, compensation_year: false,
        notice_date: Time.zone.parse('2017/01/01'), resigned_date: Time.zone.parse('2017/01/01'),
        notice_period_compensation: true, compensation_year: true, is_in_whitelist: true
    }

    # < 1
    career_record_a = create(:career_record, basic_params.merge(user_id: user_a.id, career_begin: Time.zone.parse('2017/01/01'), career_end: Time.zone.parse('2017/01/20')))
    # 1 ~ 3
    career_record_b = create(:career_record, basic_params.merge(user_id: user_b.id, career_begin: Time.zone.parse('2015/01/01'), career_end: Time.zone.parse('2017/01/20')))
    # 3 ~ 5
    career_record_c = create(:career_record, basic_params.merge(user_id: user_c.id, career_begin: Time.zone.parse('2013/01/01'), career_end: Time.zone.parse('2017/01/20')))
    # > 5
    career_record_d = create(:career_record, basic_params.merge(user_id: user_d.id, career_begin: Time.zone.parse('2010/01/01'), career_end: Time.zone.parse('2017/01/20')))

    career_record_e = create(:career_record, basic_params.merge(user_id: user_e.id, career_begin: Time.zone.parse('2010/01/01'), career_end: Time.zone.parse('2017/01/20')))
    user_a.profile.send(:edit_field, {field: 'date_of_employment', new_value: '2017/01/01', section_key: 'position_information'}.with_indifferent_access)
    user_b.profile.send(:edit_field, {field: 'date_of_employment', new_value: '2015/01/01', section_key: 'position_information'}.with_indifferent_access)
    user_c.profile.send(:edit_field, {field: 'date_of_employment', new_value: '2013/01/01', section_key: 'position_information'}.with_indifferent_access)
    user_d.profile.send(:edit_field, {field: 'date_of_employment', new_value: '2010/01/01', section_key: 'position_information'}.with_indifferent_access)
    user_e.profile.send(:edit_field, {field: 'date_of_employment', new_value: '2010/01/01', section_key: 'position_information'}.with_indifferent_access)
    user_a.profile.save
    user_b.profile.save
    user_c.profile.save
    user_d.profile.save
    user_e.profile.save
    User.all.includes(:career_records).each { |u|
      TimelineRecordService.update_valid_date(u)
    }
    resignation_record_a = create(:resignation_record, resignation_params.merge({ user_id: user_a.id, employment_status: 'informal_employees', final_work_date: Time.zone.parse('2017/01/01') }))
    resignation_record_b = create(:resignation_record, resignation_params.merge({ user_id: user_b.id, employment_status: 'formal_employees', final_work_date: Time.zone.parse('2017/01/01') }))
    resignation_record_c = create(:resignation_record, resignation_params.merge({ user_id: user_c.id, employment_status: 'director', final_work_date: Time.zone.parse('2017/01/01') }))
    resignation_record_d = create(:resignation_record, resignation_params.merge({ user_id: user_d.id, employment_status: 'formal_employees', final_work_date: Time.zone.parse('2017/01/01') }))
    params = {
        date_begin: Time.zone.parse('2016/01/01'),
        date_end: Time.zone.parse('2017/10/01'),
        resigned_reason: %w(resignation termination company_transfer_personal_request company_transfer_department_request retirement others lay_off)
    }
    get turnover_rate_index_url(params)
    assert_response :success
    byebug
  end
end
