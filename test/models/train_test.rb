require "test_helper"

describe Train do
  let(:train) { Train.new }

  it "must be valid" do
    value(train).must_be :valid?
  end
end
