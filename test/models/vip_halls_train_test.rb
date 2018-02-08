require "test_helper"

describe VipHallsTrain do
  let(:vip_halls_train) { VipHallsTrain.new }

  it "must be valid" do
    value(vip_halls_train).must_be :valid?
  end
end
