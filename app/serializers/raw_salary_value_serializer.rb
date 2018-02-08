class RawSalaryValueSerializer < ActiveModel::Serializer
  attributes *SalaryValue.column_names, :value

  def decimal_value
    result = object.decimal_value
    # 2 位 58 59 60 61 63 64 65 66 68 71 72 73 74 76 77 78 81 82 83 84 86 87 88 89 91 92 93 94 96 92 98 99 101 102 103 104 106 107 109 111 112 113 114 118 119 120 121 123 124 125 126 128 129 130 131 207
    # 2 位 125 126 128 129 130 131 207
    round_two = [
        52, 53, 54, 55, 57, 58, 59, 60, 62, 65, 66, 67, 68, 70, 71, 72, 75, 76, 77, 78,
        80, 81, 82, 83, 85, 86, 87, 88, 90, 91, 92, 93, 95, 96, 97, 98, 100, 101, 103,
        105, 106, 107, 108, 112, 113, 114, 115, 225, 226, 227, 228, 230, 231, 232, 233, 192
    ]
    return (format('%.4f', result) rescue nil) if object.salary_column_id == 73
    return (format('%.2f', result) rescue nil) if round_two.include? object.salary_column_id
    return (format('%.0f', result) rescue nil)
  end

  def value
    if object.string_value
      object.string_value
    elsif object.decimal_value
      result = object.decimal_value
      # 2 位 58 59 60 61 63 64 65 66 68 71 72 73 74 76 77 78 81 82 83 84 86 87 88 89 91 92 93 94 96 92 98 99 101 102 103 104 106 107 109 111 112 113 114 118 119 120 121 123 124 125 126 128 129 130 131 207
      # 2 位 125 126 128 129 130 131 207
      round_two = [
          52, 53, 54, 55, 57, 58, 59, 60, 62, 65, 66, 67, 68, 70, 71, 72, 75, 76, 77, 78,
          80, 81, 82, 83, 85, 86, 87, 88, 90, 91, 92, 93, 95, 96, 97, 98, 100, 101, 103,
          105, 106, 107, 108, 112, 113, 114, 115, 225, 226, 227, 228, 230, 231, 232, 233, 192
      ]
      return (format('%.4f', result) rescue nil) if object.salary_column_id == 73
      return (format('%.2f', result) rescue nil) if round_two.include? object.salary_column_id
      return (format('%.0f', result) rescue nil)
    elsif object.integer_value
      object.integer_value
    elsif object.date_value
      object.date_value
    elsif object.object_value
      object.object_value
    elsif [false, true].include? object.boolean_value
      object.boolean_value
    end
  end

end