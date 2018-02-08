class DimissionSerializer < ActiveModel::Serializer
  attributes *Dimission.column_names
  belongs_to :user
  belongs_to :creator
  belongs_to :group
  has_many :dimission_follow_ups
  has_many :approval_items
  has_many :attachment_items
end