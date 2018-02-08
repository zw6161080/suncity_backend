require "test_helper"

describe VipHallsTrainer do
  let(:vip_halls_trainer) { VipHallsTrainer.new }

  it "must be valid" do
    value(vip_halls_trainer).must_be :valid?
  end
end
