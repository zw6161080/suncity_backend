class RawTitleSerializer < ActiveModel::Serializer
  attributes *Title.create_params
end