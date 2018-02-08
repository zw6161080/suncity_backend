class TrainTemplateTypeSerializer < ActiveModel::Serializer
  attributes *TrainTemplateType.create_params

end
