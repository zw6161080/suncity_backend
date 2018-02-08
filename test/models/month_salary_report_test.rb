require "test_helper"

class MonthSalaryReportTest < ActiveSupport::TestCase
  setup do
    OccupationTaxSetting.load_predefined
    User.destroy_all
  end

  def test_create
    SalaryColumn.generate
    MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_year, salary_type: :on_duty)
    assert_equal MonthSalaryReport.first.status, 'not_calculating'
  end

  def test_calculating
    test_user = create_test_user
    test_user1 = create_test_user
    test_user2 = create_test_user
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_year, salary_type: :on_duty)
    AccountingMonthSalaryReportJob.perform_now(msr)
    assert_equal msr.reload.status, 'completed'
    assert_equal SalaryValue.where(user_id: test_user.id,salary_column_id: 1).first.string_value, test_user.empoid
    AccountingMonthSalaryReportJob.perform_now(msr)
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_year, salary_type: :on_duty)
    AccountingMonthSalaryReportJob.perform_now(msr)
  end

  def test_calculating_by_left
    test_user = create_test_user
    SalaryColumn.generate
    @salary_column_template = SalaryColumnTemplate.create(name: 'test')
    @salary_column_template.salary_columns << SalaryColumn.where(id: [1,2])
    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_year, salary_type: :left)
    msr.calculate_leaving_salary_record_by_user(test_user)
    assert_equal SalaryValue.where(user_id: test_user.id, salary_column_id: 1).first.string_value, test_user.empoid
    assert_equal SalaryValue.where(user_id: test_user.id, salary_column_id: 1).first.salary_type, :left.to_s
  end


  def month_salary_report
    @month_salary_report ||= MonthSalaryReport.new
  end

  # def test_valid
  #   assert month_salary_report.valid?
  # end
end
