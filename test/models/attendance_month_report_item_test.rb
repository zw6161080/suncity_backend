require 'test_helper'

class AttendanceMonthReportItemTest < ActiveSupport::TestCase
  setup do
    User.destroy_all

    create_test_user(101)
    create_test_user(102)
    create_test_user(103)
    @test_user = User.find(101)
  end

  test "generate single item" do
    year_month_date = Time.zone.local(2017, 9, 1)
    AttendanceMonthReportItem.generate(@test_user, year_month_date)
    AttendanceMonthReportItem.generate(@test_user, year_month_date)

    month_range = year_month_date.beginning_of_month...year_month_date.end_of_month
    query = AttendanceMonthReportItem.where(user: @test_user, year_month: month_range)

    assert_equal 1, query.count
    AttendanceMonthReportItem.column_names.each do |column_name|
      assert_not_nil query.first[column_name]
    end
  end

  test "generate all items" do
    year_month_date = Time.zone.local(2017, 9, 1)
    AttendanceMonthReportItem.generate_all(year_month_date)

    User.all.each do |user|
      query = AttendanceMonthReportItem.where(user: user, year_month: year_month_date)
      assert_equal 1, query.count
      item = query.first
      AttendanceMonthReportItem.column_names.each do |column_name|
        assert_not_nil item[column_name]
      end
    end
  end
end
