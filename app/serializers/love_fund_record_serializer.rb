class LoveFundRecordSerializer < ActiveModel::Serializer
  attributes *LoveFundRecord.column_names
  belongs_to :creator
end