class SalaryElementFactorSerializer < ActiveModel::Serializer
  attributes *SalaryElementFactor.column_names

  def numerator
    if object.numerator.nil?
      nil
    else
      '%g' % ( '%.10f' % object.numerator )
    end
  end

  def denominator
    if object.denominator.nil?
      nil
    else
      '%g' % ( '%.10f' % object.denominator )
    end
  end

  def value
    if object.value.nil?
      nil
    else
      '%g' % ( '%.10f' % object.value )
    end
  end

end