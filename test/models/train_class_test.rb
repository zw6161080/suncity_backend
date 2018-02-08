require "test_helper"

describe TrainClass do
  let(:train_class) { TrainClass.new }

  it "must be valid" do
    value(train_class).must_be :valid?
  end
end
