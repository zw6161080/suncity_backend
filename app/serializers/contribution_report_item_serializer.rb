class ContributionReportItemSerializer < ActiveModel::Serializer
  attributes *ContributionReportItem.column_names.map { |name| name.to_sym }

  belongs_to :user
  belongs_to :department
  belongs_to :position

end
