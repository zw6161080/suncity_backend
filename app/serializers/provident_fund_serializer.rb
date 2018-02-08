class ProvidentFundSerializer < ActiveModel::Serializer
  attributes *ProvidentFund.column_names
end
