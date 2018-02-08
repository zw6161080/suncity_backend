require "test_helper"

describe StudentEvaluation do
  let(:student_evaluation) { StudentEvaluation.new }

  it "must be valid" do
    value(student_evaluation).must_be :valid?
  end
end
