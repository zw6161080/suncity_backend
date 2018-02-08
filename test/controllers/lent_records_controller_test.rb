require 'test_helper'

class LentRecordsControllerTest < ActionDispatch::IntegrationTest
  def lent_record
    @lent_record ||= lent_records :one
  end

  def test_can_create_and_update
    user = create_profile.user
    department = create(:department, id: 1)
    position = create(:position, id: 1)
    location = create(:location, id: 1)
    user.department = department
    user.position = position
    user.save!
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :LentRecord, :macau)
    LentRecordsController.any_instance.stubs(:current_user).returns(user)
    location = create(:location)
    location_2 = create(:location)
    location.departments << user.department
    location.positions << user.position
    location_2.departments << user.department
    location_2.positions << user.position
    basic_params = {
        user_id: user.id, deployment_type: 'entry',  salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited', location_id: location.id, position_id: position.id,
        department_id: department.id, grade: position.grade, division_of_job: 'front_office', employment_status: 'informal_employees'
    }
    lent_params = {
        user_id: user.id, deployment_type: 'entry', temporary_stadium_id: location_2.id, original_hall_id: user.location_id, calculation_of_borrowing: 'do_not_adjust_the_salary'
    }
    career_record_a = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/03/01')))
    career_record_b = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/05/01'), career_end: Time.zone.parse('2017/06/01')))
    lent_record_a = create(:lent_record, lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/05'), lent_end: Time.zone.parse('2017/03/10') }))
    lent_record_b = create(:lent_record, lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/20') }))
    lent_record_c = create(:lent_record, lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/04/10'), lent_end: Time.zone.parse('2017/04/20') }))
    museum_record_a = create(:museum_record, career_record_id: career_record_a.id, user_id: user.id,
                             date_of_employment: Time.zone.parse('2017/03/02'), deployment_type: 'museum', salary_calculation: 'do_not_adjust_the_salary', location_id: location.id)
    museum_record_b = create(:museum_record, career_record_id: career_record_a.id, user_id: user.id,
                             date_of_employment: Time.zone.parse('2017/03/15'), deployment_type: 'museum', salary_calculation: 'do_not_adjust_the_salary', location_id: location.id)
    museum_record_c = create(:museum_record, career_record_id: career_record_a.id, user_id: user.id,
                             date_of_employment: Time.zone.parse('2017/04/25'), deployment_type: 'museum', salary_calculation: 'do_not_adjust_the_salary', location_id: location.id)

    TimelineRecordService.update_valid_date(user)

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/02') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/03') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/03'), lent_end: Time.zone.parse('2017/03/07') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/16') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/16'), lent_end: Time.zone.parse('2017/03/19') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_lent_records_url, params: lent_params.merge({ career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/16'), lent_end: Time.zone.parse('2017/03/21') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_a.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/16'), lent_end: Time.zone.parse('2017/03/21') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_a.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/02'), lent_end: Time.zone.parse('2017/03/10') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_a.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/04'), lent_end: Time.zone.parse('2017/03/14') })
    assert_response :success
    assert_equal json_res['result'], true

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_a.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/05'), lent_end: Time.zone.parse('2017/03/16') })
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_b.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/20'), lent_end: Time.zone.parse('2017/04/09') })
    assert_response :success
    assert_equal json_res['result'], true

    post can_update_lent_records_url, params: lent_params.merge({ id: lent_record_b.id, career_record_id: career_record_a.id, lent_begin: Time.zone.parse('2017/03/20'), lent_end: Time.zone.parse('2017/04/11') })
    assert_response :success
    assert_equal json_res['result'], false

  end

  def can_update

  end

  def _test_index
    get lent_records_url
    assert_response :success
  end

  def test_create
    test_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :LentRecord, :macau)
    LentRecordsController.any_instance.stubs(:current_user).returns(test_user)
    LentRecordsController.any_instance.stubs(:authorize).returns(true)
    department = create(:department, id: test_user.department_id)
    position = create(:position, id: test_user.position_id)
    career_record = create(:career_record, department_id:department.id, position_id: position.id, career_begin: '2017/01/01', valid_date: '2017/01/01', invalid_date: '2018/02/01', user_id: test_user.id )
    location_2 = test_user.department.locations.create()
    position.locations << location_2
    assert_difference('LentRecord.count') do
      params = {
        lent_begin: Time.zone.now,
        user_id: test_user.id,
        deployment_type: 'entry',
        temporary_stadium_id: location_2.id,
        calculation_of_borrowing: 'do_not_adjust_the_salary',
      }
      post lent_records_url, params: params
    end
    assert_response 201

    get lent_information_options_lent_records_url
    assert_response :ok
    assert_equal json_res['deployment_type'], Config.get_all_option_from_selects(:deployment_type)

    get index_by_user_lent_records_url({user_id: test_user.id})
    assert_response 200
    test_user.add_role(@admin_role)
    get index_by_user_lent_records_url({user_id: test_user.id})
    assert_response :ok
    assert_equal json_res.count, 1

    patch lent_record_url(LentRecord.last), params: {
      deployment_type: 'through_the_probationary_period'
    }
    assert_response 200
    assert_equal LentRecord.last.deployment_type, 'through_the_probationary_period'

    assert_difference('LentRecord.count', -1) do
      delete lent_record_url(LentRecord.last)
    end

    assert_response 204
  end

  def _test_show
    get lent_record_url(lent_record)
    assert_response :success
  end

  def _test_update
    patch lent_record_url(lent_record), params: { lent_record: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('LentRecord.count', -1) do
      delete lent_record_url(lent_record)
    end

    assert_response 204
  end
end
