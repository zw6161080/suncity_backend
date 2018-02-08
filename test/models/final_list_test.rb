require "test_helper"

describe FinalList do
  let(:final_list) { FinalList.new }

  it "must be valid" do
    value(final_list).must_be :valid?
  end
end
