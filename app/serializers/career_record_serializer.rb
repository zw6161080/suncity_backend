class CareerRecordSerializer < ActiveModel::Serializer
  attributes *CareerRecord.column_names

  belongs_to :inputer, class_name: 'User', foreign_key: 'inputer_id'
end
