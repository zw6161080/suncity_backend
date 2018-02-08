class SalaryElementSerializer < ActiveModel::Serializer
  attributes *SalaryElement.column_names

  has_many :salary_element_factors

  def display_template
    factors = object.salary_element_factors.map do |factor|
      numerator = factor.numerator.nil? ? '0' : '%g' % ( '%.10f' % factor.numerator )
      denominator = factor.denominator.nil? ? '0' : '%g' % ( '%.10f' % factor.denominator )
      val =  factor.value.nil? ? '0' : '%g' % ( '%.10f' % factor.value )
      value = factor.factor_type == 'fraction' ? "#{numerator}/#{denominator}" : val
      [factor.key, value]
    end.to_h
    object.display_template % factors.symbolize_keys
  end
end
