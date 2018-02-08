class AwardRecordSerializer < ActiveModel::Serializer
  attributes *AwardRecord.column_names
  belongs_to :creator
end
