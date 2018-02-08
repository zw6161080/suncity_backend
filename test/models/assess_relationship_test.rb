require "test_helper"

class AssessRelationshipTest < ActiveSupport::TestCase
  def assess_relationship
    @assess_relationship ||= AssessRelationship.new
  end

  def test_valid
    assert assess_relationship.valid?
  end
end
