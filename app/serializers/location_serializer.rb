class LocationSerializer < ActiveModel::Serializer
  attributes *Location.column_names
end