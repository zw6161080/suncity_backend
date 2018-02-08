require "test_helper"

describe ClientCommentTrack do
  let(:client_comment_track) { ClientCommentTrack.new }

  it "must be valid" do
    value(client_comment_track).must_be :valid?
  end
end
