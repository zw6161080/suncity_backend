class UserFromProvidentFundSerializer < ActiveModel::Serializer
  attributes :id,
             :empoid,
             :chinese_name,
             :english_name,
             :simple_chinese_name,
             :id_card_number,
             :email,
             :company_name,
             :employment_status,
             :grade,
             :position_id,
             :location_id,
             :department_id,
             :career_entry_date

  belongs_to :position
  belongs_to :location
  belongs_to :department
  def company_name
    Config
        .get('selects')
        .dig('company_name.options')
        &.find { |opt| opt['key'] == object.company_name }
  end

  def employment_status
    Config
        .get('selects')
        .dig('employment_status.options')
        &.find { |opt| opt['key'] == object.employment_status }
  end
end
