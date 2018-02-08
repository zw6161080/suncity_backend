class DimissionFollowUpSerializer < ActiveModel::Serializer
  attributes *DimissionFollowUp.column_names
  belongs_to :handler
end