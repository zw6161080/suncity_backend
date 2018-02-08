require "test_helper"

describe TrainRecord do
  let(:train_record) { TrainRecord.new }

  it "must be valid" do
    value(train_record).must_be :valid?
  end
end
