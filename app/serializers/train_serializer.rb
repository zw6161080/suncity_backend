class TrainSerializer < ActiveModel::Serializer
  attributes *Train.create_params

end