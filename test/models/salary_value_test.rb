require "test_helper"

class SalaryValueTest < ActiveSupport::TestCase

  def test_update_value
    SalaryColumn.generate
    test_user = create_test_user
    salary_value = SalaryValue.create(string_value: '1', user_id: test_user.id, salary_column_id: 1,
                                      year_month: Time.zone.now.beginning_of_year, salary_type: 'on_duty' )
    salary_value.update_value('2')
    assert_equal SalaryValue.first.string_value, '2'
    salary_value_165 = SalaryValue.create(string_value: 'remark', user_id: test_user.id, salary_column_id: 165,
                                      year_month: Time.zone.now.beginning_of_year, salary_type: 'on_duty' )
    salary_value_165.update_value(nil)
    assert_equal SalaryValue.last.string_value, nil
    salary_value_165.update_value('')
    assert_equal SalaryValue.last.string_value, ''
  end


  def salary_value
    @salary_value ||= SalaryValue.new
  end

  def _test_valid
    assert salary_value.valid?
  end
end
