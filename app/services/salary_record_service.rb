class SalaryRecordService
  class << self
    def reset_change_record(user)
      user.month_salary_change_records.destroy_all
      targets = user.salary_records.order_by(:salary_begin, :asc)
      if targets.count >= 2
        targets.each_with_index do |record, index|
          updated_salary_record = targets[index + 1]
          if updated_salary_record
            MonthSalaryChangeRecord.find_or_create_by(user_id: user.id, original_salary_record_id: record.id, updated_salary_record_id: updated_salary_record.id)
          end
        end
      end
    end

    def set_all_user_change_records
      User.all.includes(:salary_records).each do |user|
        user.month_salary_change_records.destroy_all
        targets = user.salary_records.order_by(:salary_begin, :asc)
        if targets.count >= 2
          targets.each_with_index do |record, index|
            updated_salary_record = targets[index + 1]
            if updated_salary_record
              MonthSalaryChangeRecord.find_or_create_by(user_id: user.id, original_salary_record_id: record.id, updated_salary_record_id: updated_salary_record.id)
            end
          end
        end
      end
    end

  end
end
