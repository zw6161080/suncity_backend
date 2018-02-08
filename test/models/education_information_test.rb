require "test_helper"

class EducationInformationTest < ActiveSupport::TestCase
  def education_information
    @education_information ||= EducationInformation.new
  end

  def test_valid
    assert education_information.valid?
  end
end
