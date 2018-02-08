require 'test_helper'

class CareerRecordsControllerTest < ActionDispatch::IntegrationTest

  def career_record
    @career_record ||= career_records :one
  end

  def _test_index
    get career_records_url
    assert_response :success
  end

  def test_update_check_method
    user = create_profile.user
    department = create(:department)
    user.department_id = department.id
    user.save
    CareerRecordsController.any_instance.stubs(:current_user).returns(user)
    CareerRecordsController.any_instance.stubs(:authorize).returns(true)
    location = create(:location)
    location_2 = create(:location)
    location.departments << user.department
    position = create(:position)
    basic_params = {
        user_id: user.id, deployment_type: 'entry',  salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited', location_id: location.id, position_id: position.id,
        department_id: department.id, grade: position.grade, division_of_job: 'front_office', employment_status: 'informal_employees'
    }
    lent_params = {
        user_id: user.id, deployment_type: 'entry', temporary_stadium_id: location.id, original_hall_id: user.location_id, calculation_of_borrowing: 'do_not_adjust_the_salary'
    }
    career_record_a = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/01/01'), career_end: Time.zone.parse('2017/01/20')))
    career_record_b = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/02/01'), career_end: Time.zone.parse('2017/03/31')))
    career_record_c = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2018/01/01')))
    lent_record_a = create(:lent_record, lent_params.merge({ career_record_id: career_record_c.id, lent_begin: Time.zone.parse('2018/01/10') }))
    museum_record_a = create(:museum_record, career_record_id: career_record_c.id, user_id: user.id,
                             date_of_employment: Time.zone.parse('2018/01/20'), deployment_type: 'museum', salary_calculation: 'do_not_adjust_the_salary', location_id: location.id)

    post can_update_career_records_url, params: basic_params.merge(id: career_record_a.id, career_begin: Time.zone.parse('2016/01/02'), career_end: Time.zone.parse('2016/02/20'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_update_career_records_url, params: basic_params.merge(id: career_record_a.id, career_begin: Time.zone.parse('2017/01/02'), career_end: Time.zone.parse('2016/02/20'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_career_records_url, params: basic_params.merge(id: career_record_c.id, career_begin: Time.zone.parse('2018/01/02'), career_end: Time.zone.parse('2018/01/20'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_update_career_records_url, params: basic_params.merge(id: career_record_c.id, location_id: location_2.id, career_begin: Time.zone.parse('2018/01/02'), career_end: Time.zone.parse('2018/01/20'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_career_records_url, params: basic_params.merge(id: career_record_c.id, career_begin: Time.zone.parse('2018/01/11'), career_end: Time.zone.parse('2018/01/20'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_update_career_records_url, params: basic_params.merge(id: career_record_c.id, career_begin: Time.zone.parse('2018/01/02'), career_end: Time.zone.parse('2018/01/21'))
    assert_response :success
    assert_equal json_res['result'], true
  end

  def test_create_check_method
    user = create_profile.user
    department = create(:department)
    user.department_id = department.id
    user.save
    CareerRecordsController.any_instance.stubs(:current_user).returns(user)
    CareerRecordsController.any_instance.stubs(:authorize).returns(true)
    location = create(:location)
    location.departments << user.department
    position = create(:position)
    basic_params = {
        user_id: user.id, deployment_type: 'entry',  salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited', location_id: location.id, position_id: position.id,
        department_id: department.id, grade: position.grade, division_of_job: 'front_office', employment_status: 'informal_employees'
    }
    lent_params = {
        user_id: user.id, deployment_type: 'entry', temporary_stadium_id: location.id, original_hall_id: user.location_id, calculation_of_borrowing: 'do_not_adjust_the_salary'
    }
    career_record_a = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/01/01'), career_end: Time.zone.parse('2017/01/20')))
    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2016/01/02'), career_end: Time.zone.parse('2016/02/20'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2017/01/02'), career_end: Time.zone.parse('2017/02/20'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2016/01/02'), career_end: Time.zone.parse('2017/01/20'))
    assert_response :success
    assert_equal json_res['result'], false

    career_record_b = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2017/02/01'), career_end: Time.zone.parse('2017/03/31')))

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2017/02/02'), career_end: Time.zone.parse('2017/02/20'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2017/01/20'), career_end: Time.zone.parse('2017/01/30'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2017/01/21'), career_end: Time.zone.parse('2017/02/01'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2017/01/21'), career_end: Time.zone.parse('2017/01/30'))
    assert_response :success
    assert_equal json_res['result'], true

    career_record_c = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2018/01/01')))
    career_record_d = create(:career_record, basic_params.merge(career_begin: Time.zone.parse('2018/02/01')))

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/09'), career_end: Time.zone.parse('2018/01/30'))
    assert_response :success
    assert_equal json_res['result'], true

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/21'), career_end: Time.zone.parse('2018/02/30'))
    assert_response :success
    assert_equal json_res['result'], false

    lent_record_a = create(:lent_record, lent_params.merge({ career_record_id: career_record_c.id, lent_begin: Time.zone.parse('2018/01/10') }))

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/09'), career_end: Time.zone.parse('2018/01/30'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/11'), career_end: Time.zone.parse('2018/01/30'))
    assert_response :success
    assert_equal json_res['result'], true

    museum_record_a = create(:museum_record, career_record_id: career_record_c.id, user_id: user.id,
                             date_of_employment: Time.zone.parse('2018/01/20'), deployment_type: 'museum', salary_calculation: 'do_not_adjust_the_salary', location_id: location.id)

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/11'), career_end: Time.zone.parse('2018/01/30'))
    assert_response :success
    assert_equal json_res['result'], false

    post can_create_career_records_url, params: basic_params.merge(career_begin: Time.zone.parse('2018/01/21'), career_end: Time.zone.parse('2018/01/30'))
    assert_response :success
    assert_equal json_res['result'], true
  end

  def test_create
    location = create(:location, id: 1)
    location = create(:location)
    department = create(:department)
    position = create(:position)
    test_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :CareerRecord, :macau)
    test_user.add_role(@admin_role)

    CareerRecordsController.any_instance.stubs(:current_user).returns(test_user)
    CareerRecordsController.any_instance.stubs(:authorize).returns(true)
    assert_difference('CareerRecord.count') do
      params = {
        career_begin: Time.zone.now.beginning_of_day,
        user_id: test_user.id,
        deployment_type: 'entry',
        salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited',
        location_id: test_user.location_id,
        position_id: test_user.position_id,
        department_id: test_user.department_id,
        group_id: create(:group, id: 10).id,
        grade: test_user.grade,
        division_of_job: 'front_office',
        employment_status: 'informal_employees'
      }
      post career_records_url, params: params
      assert_response 201
    end
    assert test_user.reload.group_id == 10
    patch career_record_url(CareerRecord.last), params: {
        career_begin: Time.zone.now.beginning_of_day,
        division_of_job: 'back_office',
        company_name: 'tian_mao_yi_hang',
        location_id: location.id,
        position_id: position.id,
        department_id: department.id,
        grade: 2,
        employment_status: 'formal_employees',
    }
    assert_response 200
    assert_equal CareerRecord.last.division_of_job, 'back_office'
    assert_equal CareerRecord.last.company_name, 'tian_mao_yi_hang'
    assert_equal CareerRecord.last.location_id, location.id
    assert_equal CareerRecord.last.position_id, position.id
    assert_equal CareerRecord.last.department_id, department.id
    assert_equal CareerRecord.last.grade, 2
    assert_equal CareerRecord.last.employment_status, 'formal_employees'



    get index_by_user_career_records_url, params: {
        user_id: test_user.id
    }
    assert_response 200
    assert_equal json_res.count , 1

    get career_information_options_career_records_url
    assert_response 200
    assert_equal json_res['division_of_job'].count , 2

    assert_difference('CareerRecord.count', 0) do
      delete career_record_url(CareerRecord.last)
    end


  end

  def _test_show
    get career_record_url(career_record)
    assert_response :success
  end

  def _test_update
    patch career_record_url(career_record), params: { career_record: {  } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('CareerRecord.count', -1) do
      delete career_record_url(career_record)
    end

    assert_response 204
  end
end
