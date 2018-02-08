require "test_helper"

describe OnlineMaterial do
  let(:online_material) { OnlineMaterial.new }

  it "must be valid" do
    value(online_material).must_be :valid?
  end
end
