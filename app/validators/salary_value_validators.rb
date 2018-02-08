module SalaryValueValidators
  class SalaryValueUniquenessValidator <ActiveModel:: Validator
    def validate(record)
      if  record.resignation_record_id
        if SalaryValue.where(user_id: record.user_id, year_month: record.year_month, salary_column_id: record.salary_column_id, resignation_record_id: record.resignation_record_id).count > 0 &&
          !record.persisted?
          record.errors[:base] << "This salary_value #{record} has been created"
        end
      else
        if SalaryValue.where(user_id: record.user_id, year_month: record.year_month, salary_column_id: record.salary_column_id, salary_type: record.salary_type).count > 0 &&
          !record.persisted?
          record.errors[:base] << "This salary_value #{record} has been created"
        end
      end
    end

  end
end