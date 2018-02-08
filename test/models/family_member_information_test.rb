require "test_helper"

class FamilyMemberInformationTest < ActiveSupport::TestCase
  def family_member_information
    @family_member_information ||= FamilyMemberInformation.new
  end

  def test_valid
    assert family_member_information.valid?
  end
end
