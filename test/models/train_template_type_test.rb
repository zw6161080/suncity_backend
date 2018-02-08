require "test_helper"

describe TrainTemplateType do
  let(:train_template_type) { TrainTemplateType.new }

  it "must be valid" do
    value(train_template_type).must_be :valid?
  end
end
