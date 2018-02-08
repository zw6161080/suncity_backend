require "test_helper"

describe TrainingPaper do
  let(:training_paper) { TrainingPaper.new }

  it "must be valid" do
    value(training_paper).must_be :valid?
  end
end
