class MedicalRecordSerializer < ActiveModel::Serializer
  attributes *MedicalRecord.column_names
  belongs_to :creator
end
