require "test_helper"

class MonthSalaryAttachmentTest < ActiveSupport::TestCase
  def month_salary_attachment
    @month_salary_attachment ||= MonthSalaryAttachment.new
  end

  def test_valid
    assert month_salary_attachment.valid?
  end
end
