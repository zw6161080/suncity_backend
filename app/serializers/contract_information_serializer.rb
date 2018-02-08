class ContractInformationSerializer < ActiveModel::Serializer
  attributes :id, :profile_id, :contract_information_type_id, :attachment_id, :description, :creator_id, :file_name
end
