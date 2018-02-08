require "test_helper"

class MuseumRecordTest < ActiveSupport::TestCase
  test 'create museum ' do
    test_user =  create_test_user
    params = {
      date_of_employment: Time.zone.now,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      location_id: test_user.location_id,
    }
    test_ca = MuseumRecord.create(params)
    assert_equal test_ca.reload.status, 'being_valid'
  end

  private
    def museum_record
      @museum_record ||= MuseumRecord.new
    end

    def test_valid
      assert museum_record.valid?
    end
end
