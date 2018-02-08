require "test_helper"

class LentRecordTest < ActiveSupport::TestCase
  test 'lent_record' do
    test_user =  create_test_user
    params = {
      lent_begin: Time.zone.now,
      user_id: test_user.id,
      deployment_type: 'entry',
      original_hall_id: test_user.location_id,
      temporary_stadium_id: test_user.location_id,
      calculation_of_borrowing: 'do_not_adjust_the_salary',
      return_compensation_calculation: 'do_not_adjust_the_salary'
    }
    test_ca = LentRecord.create(params)
    assert_equal test_ca.reload.status, 'being_valid'
  end


  test 'can_lent_by_department' do
    department_1 = create(:department)
    location_1 = create(:location)
    location_2 = create(:location)
    department_1.locations << location_1
    test_user = create_test_user
    test_user.update_columns(department_id: department_1.id)
    ProfileService.stubs(:department).with(any_parameters).returns(department_1)
    params = {
      lent_begin: Time.zone.now,
      user_id: test_user.id,
      deployment_type: 'entry',
      original_hall_id: test_user.location_id,
      temporary_stadium_id: location_1.id,
      calculation_of_borrowing: 'do_not_adjust_the_salary',
      return_compensation_calculation: 'do_not_adjust_the_salary'
    }
    test_ca = LentRecord.create(params)
    assert test_ca.valid?
    ProfileService.stubs(:department).with(any_parameters).returns(department_1)
    params = {
      lent_begin: Time.zone.now,
      user_id: test_user.id,
      deployment_type: 'entry',
      original_hall_id: test_user.location_id,
      temporary_stadium_id: location_2.id,
      calculation_of_borrowing: 'do_not_adjust_the_salary',
      return_compensation_calculation: 'do_not_adjust_the_salary'
    }
    test_ca = LentRecord.create(params)
    assert_not test_ca.valid?

  end

  private
  def lent_record
    @lent_record ||= LentRecord.new
    end

    def test_valid
      assert lent_record.valid?
    end
end
