class SocialSecurityFundItemSerializer < ActiveModel::Serializer
  attributes *SocialSecurityFundItem.column_names

  belongs_to :user, serializer: UserWithCardProfileSerializer
  belongs_to :department
  belongs_to :position

  def employment_status
    Config
      .get('selects')
      .dig('employment_status.options')
      &.find { |opt| opt['key'] == object.employment_status }
  end

  def company_name
    Config
      .get('selects')
      .dig('company_name.options')
      &.find { |opt| opt['key'] == object.company_name }
  end
end
