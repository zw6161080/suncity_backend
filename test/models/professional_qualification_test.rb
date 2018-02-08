require "test_helper"

class ProfessionalQualificationTest < ActiveSupport::TestCase
  def professional_qualification
    @professional_qualification ||= ProfessionalQualification.new
  end

  def test_valid
    assert professional_qualification.valid?
  end
end
