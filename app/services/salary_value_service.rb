class SalaryValueService
  class << self
    def get_index_salary_value_by_salary_value_id(id)
      salary_value = SalaryValue.find(id)
      if salary_value.resignation_record_id
        SalaryValue.find_by(salary_column_id: 0, resignation_record_id: salary_value.resignation_record_id)
      else
        SalaryValue.find_by(year_month: salary_value.year_month, salary_column_id: 0, salary_type: :on_duty)
      end
    end
  end
end
