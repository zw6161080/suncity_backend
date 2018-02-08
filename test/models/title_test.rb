require "test_helper"

describe Title do
  let(:title) { Title.new }

  it "must be valid" do
    value(title).must_be :valid?
  end
end
