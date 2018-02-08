require "test_helper"

class SalaryValuesControllerTest < ActionDispatch::IntegrationTest
  # def test_sanity
  #   flunk "Need real tests"
  # end


  def test_update_value
    SalaryColumn.generate
    test_user = create_test_user
    salary_value = SalaryValue.create(string_value: '1', user_id: test_user.id, salary_column_id: 1,
                                      year_month: Time.zone.now.beginning_of_year, salary_type: 'on_duty' )

    patch update_value_salary_value_url(salary_value.id),params: {
      value: '2'
    }
    assert_equal SalaryValue.find(salary_value.id).string_value, '2'
  end
end
