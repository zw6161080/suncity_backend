require "test_helper"

class SalaryColumnTest < ActiveSupport::TestCase

  def test_preload
    SalaryColumn.generate
    count_tag1 = SalaryColumn.count
    assert SalaryColumn.count > 0
    SalaryColumn.generate
    count_tag2 = SalaryColumn.count
    assert count_tag1 == count_tag2
  end

  def salary_column
    @salary_column ||= SalaryColumn.new
  end

  def test_valid
    assert salary_column.valid?
  end
end
