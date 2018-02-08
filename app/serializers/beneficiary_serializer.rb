class BeneficiarySerializer < ActiveModel::Serializer
  attributes Beneficiary.column_names
end
