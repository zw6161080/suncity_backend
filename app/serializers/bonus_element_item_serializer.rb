class BonusElementItemSerializer < ActiveModel::Serializer
  attributes :id
  has_one :user
  has_many :bonus_element_item_values
end
