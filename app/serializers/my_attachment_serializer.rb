class MyAttachmentSerializer < ActiveModel::Serializer
  attributes *MyAttachment.column_names
end
