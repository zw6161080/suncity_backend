module SalaryRecordValidators
  class SalaryRecordValidator < ActiveModel:: Validator
    def validate(record)
      if  record.salary_end && record.salary_begin > record.salary_end
        record.errors[:base] << "salary_begin > salary_end"
      end
      if  record.salary_end && !record.user.salary_records.where.not(id: record.id).empty? && (!record.user.salary_records.where.not(id: record.id).where("salary_end is not null").by_search_for_one_day(record.salary_begin).empty? || !record.user.salary_records.where.not(id: record.id).where("salary_end is not null").by_search_for_one_day(record.salary_end).empty? ||
        !record.user.salary_records.where.not(id: record.id).where("(salary_begin >= :begin AND salary_begin <= :end AND salary_end is not null) OR (salary_end >= :begin AND salary_end <= :end)", begin: record.salary_begin, end: record.salary_end).empty?)
        record.errors[:base] << "has had salary_record from: #{record.salary_begin} to: #{record.salary_end}"
      end

      if record.salary_end.nil?  && !record.user.salary_records.where.not(id: record.id).empty? && (!record.user.salary_records.where.not(id: record.id).where("salary_end is not null").by_search_for_one_day(record.salary_begin).empty? ||
        !record.user.salary_records.where.not(id: record.id).where("salary_begin >= :begin OR salary_end >= :begin", begin: record.salary_begin ).empty?)
        record.errors[:base] << "has had salary_record from: #{record.salary_begin} to: #{record.salary_end}"
      end
    end
  end
end