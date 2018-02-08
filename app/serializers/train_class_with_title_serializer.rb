class TrainClassWithTitleSerializer < ActiveModel::Serializer
  attributes *TrainClass.create_params + %w(id)
  has_one :title, serializer: RawTitleSerializer
end