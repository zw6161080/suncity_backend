class FamilyDeclarationItemSerializer < ActiveModel::Serializer
  attributes *FamilyDeclarationItem.column_names

  belongs_to :creator
  belongs_to :family_member
end
