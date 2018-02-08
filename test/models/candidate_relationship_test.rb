require "test_helper"

class CandidateRelationshipTest < ActiveSupport::TestCase
  def candidate_relationship
    @candidate_relationship ||= CandidateRelationship.new
  end

  def test_valid
    assert candidate_relationship.valid?
  end
end
