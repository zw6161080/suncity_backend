class TrainClassSerializer < ActiveModel::Serializer
  attributes *TrainClass.create_params

  has_one :train, serializer: RawTrainSerializer
  has_one :title
end