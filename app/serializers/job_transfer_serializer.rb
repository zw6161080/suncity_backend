class JobTransferSerializer < ActiveModel::Serializer
  attributes *JobTransfer.column_names
  belongs_to :user, serializer: UserSerializer
  belongs_to :inputter, serializer: UserWithPAndLAndDSerializer
  belongs_to :new_location
  belongs_to :original_location
  belongs_to :new_department
  belongs_to :original_department
  belongs_to :new_position
  belongs_to :original_position
  belongs_to :new_group
  belongs_to :original_group

  def new_company_name
    Config
      .get('selects')
      .dig('company_name.options')
      &.find { |opt| opt['key'] == object.new_company_name }
  end

  def new_employment_status
    Config
      .get('selects')
      .dig('employment_status.options')
      &.find { |opt| opt['key'] == object.new_employment_status}
  end


  def original_company_name
    Config
      .get('selects')
      .dig('company_name.options')
      &.find { |opt| opt['key'] == object.original_company_name }
  end

  def original_employment_status
    Config
      .get('selects')
      .dig('employment_status.options')
      &.find { |opt| opt['key'] == object.original_employment_status}
  end


  def salary_calculation
    Config
      .get('selects')
      .dig('salary_calculation.options')
      &.find { |opt| opt['key'] == object.salary_calculation}
  end

end
