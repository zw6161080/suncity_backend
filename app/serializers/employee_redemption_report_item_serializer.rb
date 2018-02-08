class EmployeeRedemptionReportItemSerializer < ActiveModel::Serializer
  attributes *EmployeeRedemptionReportItem.column_names.map { |name| name.to_sym }, :resigned_date, :resigned_reason
  belongs_to :user
  def resigned_date
    object.resigned_date
  end

  def resigned_reason
    object.resigned_reason
  end

  def contribution_item
    Config
        .get('selects')
        .dig('contribution_item.options')
        &.find { |opt| opt['key'] == object.contribution_item }
  end

  def vesting_percentage
    "#{object.vesting_percentage * 100}%"
  end
end
