class FinalListByTrainSerializer < ActiveModel::Serializer
  attributes *FinalList.create_params
  belongs_to :user,  serializer: UserWithPAndLAndDSerializer
  has_many :train_classes, serializer: TrainClassWithTitleSerializer


  def working_status
    object.working_status
  end

  def attendance_percentage
    object.attendance_percentage
  end

  def test_score
    object.test_score
  end
end
