class ContractInformationTypeSerializer < ActiveModel::Serializer
  attributes :id, :chinese_name, :english_name, :description, :type
end
