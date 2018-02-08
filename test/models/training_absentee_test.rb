require "test_helper"

describe TrainingAbsentee do
  let(:training_absentee) { TrainingAbsentee.new }

  it "must be valid" do
    value(training_absentee).must_be :valid?
  end
end
