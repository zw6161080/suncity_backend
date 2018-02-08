require "test_helper"

class SalaryColumnTemplateTest < ActiveSupport::TestCase
  def test_set_default
    SalaryColumnTemplate.create(name: 'test')
    assert SalaryColumnTemplate.first.default
  end

  def test_load_predefined
    SalaryColumn.generate
    SalaryColumnTemplate.load_predefined
    assert SalaryColumnTemplate.where(default: true).count > 0
  end

  def salary_column_template
    @salary_column_template ||= SalaryColumnTemplate.new
  end

  def test_valid
    assert salary_column_template.valid?
  end
end
