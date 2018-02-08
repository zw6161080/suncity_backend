require 'test_helper'

class MuseumRecordsControllerTest < ActionDispatch::IntegrationTest
  def museum_record
    @museum_record ||= museum_records :one
  end

  def test_create_and_update_check_method
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

    museum_basic_params = {
        user_id: user.id,
        deployment_type: 'museum',
        salary_calculation: 'do_not_adjust_the_salary',
        location_id: location_2.id
    }
    post can_create_museum_records_url, params: museum_basic_params.merge(date_of_employment: Time.zone.parse('2017/03/04'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_create_museum_records_url, params: museum_basic_params.merge(date_of_employment: Time.zone.parse('2017/03/05'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_museum_records_url, params: museum_basic_params.merge(id: museum_record_a.id, date_of_employment: Time.zone.parse('2017/03/21'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_update_museum_records_url, params: museum_basic_params.merge(id: museum_record_a.id, date_of_employment: Time.zone.parse('2017/03/06'))
    assert_response :success
    assert_equal json_res['result'], false

  end

  def _test_index
    get museum_records_url
    assert_response :success
  end

  def test_create
    test_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :MuseumRecord, :macau)
    MuseumRecordsController.any_instance.stubs(:current_user).returns(test_user)
    MuseumRecordsController.any_instance.stubs(:authorize).returns(true)
    department = create(:department, id: test_user.department_id)
    position = create(:position, id: test_user.position_id)
    career_record = create(:career_record, department_id:department.id, position_id: position.id, career_begin: '2017/01/01', valid_date: '2017/01/01', invalid_date: '2018/02/01', user_id: test_user.id )
    location_2 = test_user.department.locations.create()
    position.locations << location_2
    assert_difference('MuseumRecord.count') do
      params = {
        date_of_employment: Time.zone.now,
        user_id: test_user.id,
        deployment_type: 'entry',
        salary_calculation: 'do_not_adjust_the_salary',
        location_id: location_2.id,
      }
      post museum_records_url, params: params
    end

    assert_response 201

    get museum_information_options_museum_records_url
    assert_response :ok
    assert_equal json_res['deployment_type'], Config.get_all_option_from_selects(:deployment_type)

    get index_by_user_museum_records_url({user_id: test_user.id})
    assert_response 200

    test_user.add_role(@admin_role)
    get index_by_user_museum_records_url({user_id: test_user.id})
    assert_response :ok
    assert_equal json_res.count, 1

    patch museum_record_url(MuseumRecord.last), params: {
      deployment_type: 'through_the_probationary_period'
    }
    assert_response 200
    assert_equal MuseumRecord.last.deployment_type, 'through_the_probationary_period'

    assert_difference('MuseumRecord.count', -1) do
      delete museum_record_url(MuseumRecord.last)
    end

    assert_response 204



  end

  def _test_show
    get museum_record_url(museum_record)
    assert_response :success
  end

  def _test_update
    patch museum_record_url(museum_record), params: { museum_record: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('MuseumRecord.count', -1) do
      delete museum_record_url(museum_record)
    end

    assert_response 204
  end
end
