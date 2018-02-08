class RawTrainTemplateSerializer < ActiveModel::Serializer
  attributes *TrainTemplate.create_params - %w(grade)
  belongs_to :train_template_type
end
