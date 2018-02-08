require "test_helper"

class TrainRecordByTrainTest < ActiveSupport::TestCase
  def train_record_by_train
    @train_record_by_train ||= TrainRecordByTrain.new
  end

  def test_valid
    assert train_record_by_train.valid?
  end
end
