class BackgroundDeclarationSerializer < ActiveModel::Serializer
  attributes *BackgroundDeclaration.column_names
end
