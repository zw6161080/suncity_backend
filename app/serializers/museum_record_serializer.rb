class MuseumRecordSerializer < ActiveModel::Serializer
  attributes *MuseumRecord.column_names
end
