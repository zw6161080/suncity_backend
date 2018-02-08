class SalaryValueWithNewSalaryColumnIdSerializer < ActiveModel::Serializer
  attributes *SalaryValue.column_names, :value
  belongs_to :salary_column

  def value
    if object.string_value
      object.string_value
    elsif object.decimal_value
      object.decimal_value&.round(0)&.to_s&.sub(/\.\d*/, '')
    elsif object.integer_value
      object.integer_value
    elsif object.date_value
      object.date_value
    elsif object.object_value
      object.object_value
    elsif object.boolean_value
      object.boolean_value
    end
  end

  def salary_column_id
    object.salary_column_id - 1000
  end
end