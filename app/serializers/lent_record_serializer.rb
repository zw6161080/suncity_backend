class LentRecordSerializer < ActiveModel::Serializer
  attributes *LentRecord.column_names
end
