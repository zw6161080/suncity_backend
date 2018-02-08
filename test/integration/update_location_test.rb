require 'test_helper'

class UpdateLocationTest < ActionDispatch::IntegrationTest

  test 'updaet_location' do
    User.destroy_all
    test_user =  create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: original_location = test_user.location_id + 3,
      position_id: test_user.position_id,
      department_id: test_user.department_id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    assert_equal test_ca.status, 'being_valid'
    assert_equal original_location, test_user.reload.location_id
    params = {
      lent_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      original_hall_id: test_user.location_id,
      temporary_stadium_id: original_location = test_user.location_id + 1,
      calculation_of_borrowing: 'do_not_adjust_the_salary',
      return_compensation_calculation: 'do_not_adjust_the_salary'
    }
    test_lr = LentRecord.create(params)
    assert_equal test_lr.reload.status, 'being_valid'
    assert_equal original_location, test_user.reload.location_id


    params = {
      date_of_employment: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      location_id: original_location = test_user.location_id + 2 ,
    }
    test_mr = MuseumRecord.create(params)
    assert_equal test_mr.reload.status, 'being_valid'

    assert_equal original_location, test_user.reload.location_id
  end
end
