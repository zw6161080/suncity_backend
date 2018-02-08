require "test_helper"

class MonthSalaryChangeRecordTest < ActiveSupport::TestCase
  def month_salary_change_record
    @month_salary_change_record ||= MonthSalaryChangeRecord.new
  end

  def test_valid
    assert month_salary_change_record.valid?
  end
end
