class ProvidentFundListSerializer <  ActiveModel::Serializer
  attributes *ProvidentFund.column_names, :employment_of_status, :is_leave
  belongs_to :user, serializer: UserFromProvidentFundSerializer
  belongs_to :profile
  belongs_to :first_beneficiary, :class_name => 'Beneficiary', :foreign_key => "first_beneficiary_id"
  belongs_to :second_beneficiary, :class_name=> 'Beneficiary', :foreign_key => "second_beneficiary_id"
  belongs_to :third_beneficiary, :class_name => 'Beneficiary', :foreign_key => "third_beneficiary_id"

  def is_leave
    object.is_leave
  end

  def employment_of_status
    if object.is_leave
      'leave_out'
    else
      'on_working'
    end
  end

end
