class ProvidentFundMemberReportItemSerializer < ActiveModel::Serializer
  attributes *ProvidentFundMemberReportItem.column_names.map { |name| name.to_sym }
  belongs_to :user
end
