require 'test_helper'

class AccountingStatementItemTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
    @test_user = create_test_user(101)
    create_test_user(102)
    create_test_user(103)

    @test_user.location.departments << (@test_user.department)
    @test_user.location.save!

    puts 'Load BonusElement predefined'
    BonusElement.load_predefined

    puts 'Load OccupationTaxSetting predefined'
    OccupationTaxSetting.load_predefined

    puts 'Load SalaryElementCategory predefined'
    SalaryElementCategory.load_predefined
  end

  test "generate single item" do
    year_month_date = Time.zone.now
    FloatSalaryMonthEntry.create_by_year_month(year_month_date)
    BonusElementItem.generate_all(year_month_date)
    AccountingStatementMonthItem.generate(@test_user, year_month_date)
    AccountingStatementMonthItem.generate(@test_user, year_month_date)

    month_range = year_month_date.beginning_of_month...year_month_date.end_of_month
    query = AccountingStatementMonthItem.where(user: @test_user, settle_year_month: month_range)
    assert_equal 1, query.count
  end

  test "generate all items" do
    year_month_date = Time.zone.local(2017, 5, 1)
    FloatSalaryMonthEntry.create_by_year_month(year_month_date)
    BonusElementItem.generate_all(year_month_date)
    AccountingStatementMonthItem.generate_all(year_month_date)

    User.all.each do |user|
      month_range = year_month_date.beginning_of_month...year_month_date.end_of_month
      query = AccountingStatementMonthItem.where(user: user, settle_year_month: month_range)
      assert_equal 1, query.count
    end
  end
end
