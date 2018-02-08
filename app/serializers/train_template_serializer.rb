class TrainTemplateSerializer < ActiveModel::Serializer
  attributes *TrainTemplate.column_names
end
