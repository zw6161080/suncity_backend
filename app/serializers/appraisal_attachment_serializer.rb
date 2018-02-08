class AppraisalAttachmentSerializer < ActiveModel::Serializer
  attributes *AppraisalAttachment.column_names
  belongs_to :creator

end
