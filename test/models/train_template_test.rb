require "test_helper"

describe TrainTemplate do
  let(:train_template) { TrainTemplate.new }

  it "must be valid" do
    value(train_template).must_be :valid?
  end
end
