class ResignationRecordSerializer < ActiveModel::Serializer
  attributes *ResignationRecord.column_names
end
