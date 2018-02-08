class BankAutoPayReportItemSerializer < ActiveModel::Serializer
  attributes *BankAutoPayReportItem.column_names.map { |name| name.to_sym }
  attributes :id
  belongs_to :user
  belongs_to :department
  belongs_to :position

  def amount_in_mop
    object.amount_in_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def amount_in_hkd
    object.amount_in_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def company_name
    Config
      .get('selects')
      .dig('company_name.options')
      &.find { |opt| opt['key'] == object.company_name }
  end
  def cash_or_check
    object.cash_or_check
  end
  def record_type
    Config
        .get('selects')
        .dig('record_type.options')
        &.find { |opt| opt['key'] == object.record_type }
  end
end
