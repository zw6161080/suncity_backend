module SalaryCalculateHelper
  def calculate_total_count(basic_salary, bonus, attendance_bonus, house_bonus, basic_salary_template_unit, bonus_template_unit, attendance_bonus_template_unit, house_bonus_template_unit)
    total_count = BigDecimal.new(0)
    [
        {
            column: basic_salary,
            column_unit: basic_salary_template_unit
        },
        {
          column: bonus,
          column_unit: bonus_template_unit
        },
        {
            column: attendance_bonus,
            column_unit: attendance_bonus_template_unit
        },
        {
            column: house_bonus,
            column_unit: house_bonus_template_unit
        }
    ].each do |hash|
      total_count = add_single_column(total_count,hash['column'], hash['column_unit'])
    end
    {
        total_count_in_hkd: (total_count*BigDecimal('1.2')).to_s,
        total_count_in_mop: total_count.to_s
    }
  end
  private
  def  add_single_column(total_count, column, column_unit)
    if  column_unit == 'hkd'
      total_count + BigDecimal.new(column)/BigDecimal.new('1.2')
    else
      total_count + BigDecimal.new(column)
    end
  end

end