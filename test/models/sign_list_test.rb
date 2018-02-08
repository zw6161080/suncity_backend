require "test_helper"

describe SignList do
  let(:sign_list) { SignList.new }

  it "must be valid" do
    value(sign_list).must_be :valid?
  end
end
