class SignListByTrainSerializer < ActiveModel::Serializer
  attributes *SignList.create_params
  belongs_to :user,  serializer: UserWithPAndLAndDSerializer
  belongs_to :train_class, serializer: TrainClassWithTitleSerializer

  def working_status
    object.working_status
  end

  def sign_status
    object.sign_status
  end
end
