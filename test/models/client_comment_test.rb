require "test_helper"

describe ClientComment do
  let(:client_comment) { ClientComment.new }

  it "must be valid" do
    value(client_comment).must_be :valid?
  end
end
