module MonthSalaryReportValidators
  class SalaryAndYearMonth <ActiveModel:: Validator
    def validate(record)
      if MonthSalaryReport.where(year_month: record.year_month, salary_type: record.salary_type ).count >= 1
        record.errors[:base] << "This month_salary_report had one on #{record.year_month}  and #{record.salary_type}"
      end
    end

  end
end