require "test_helper"

describe SupervisorAssessment do
  let(:supervisor_assessment) { SupervisorAssessment.new }

  it "must be valid" do
    value(supervisor_assessment).must_be :valid?
  end
end
