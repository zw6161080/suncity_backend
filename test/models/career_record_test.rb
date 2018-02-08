require "test_helper"

class CareerRecordTest < ActiveSupport::TestCase
  test 'create_career_record' do
    test_user =  create_test_user
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
    assert_equal test_ca.status, 'being_valid'

    test_ca.update(position_id: position_tag = test_user.position_id + 1, department_id: department_tag = test_user.department_id + 1)

    assert_equal test_user.reload.position_id, position_tag
    assert_equal test_user.reload.department_id, department_tag
    assert_equal test_ca.career_begin.strftime("%Y/%m/%d"), test_user.profile.data['position_information']['field_values']['date_of_employment']

  end
end
