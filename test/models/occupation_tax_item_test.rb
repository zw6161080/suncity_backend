require 'test_helper'

class OccupationTaxItemTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
    @test_user = create_test_user(101)
    Location.find_or_create_by(id: @test_user.location_id)
    Department.find_or_create_by(id: @test_user.department_id)

    @test_user.location.departments << (@test_user.department)
    @test_user.location.save!

    puts 'Load BonusElement predefined'
    BonusElement.load_predefined

    puts 'Load OccupationTaxSetting predefined'
    OccupationTaxSetting.load_predefined

    puts 'Load SalaryElementCategory predefined'
    SalaryElementCategory.load_predefined
  end

  test "generate all items" do
    year_month_date = Time.zone.local(2017, 1, 1)
    FloatSalaryMonthEntry.create_by_year_month(year_month_date)
    BonusElementItem.generate_all(year_month_date)
    AccountingStatementMonthItem.generate_all(year_month_date)
    OccupationTaxItem.generate_all(year_month_date)

    User.all.each do |user|
      query = OccupationTaxItem.where(user: user, year: year_month_date.year_range)
      assert_equal 1, query.count
    end
  end
end
