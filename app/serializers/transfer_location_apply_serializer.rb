class TransferLocationApplySerializer < ActiveModel::Serializer
  attributes *TransferLocationApply.column_names
  has_many :attend_attachments
  has_many :approval_items
  has_many :transfer_location_items
end
