class AttendAttachmentSerializer < ActiveModel::Serializer
  attributes *AttendAttachment.column_names
  belongs_to :creator, serializer: UserWithPAndLAndDSerializer

end
