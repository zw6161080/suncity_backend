class LentTemporarilyApplySerializer < ActiveModel::Serializer
  attributes *LentTemporarilyApply.column_names
  has_many :attend_attachments
  has_many :approval_items
  has_many :lent_temporarily_items
end
