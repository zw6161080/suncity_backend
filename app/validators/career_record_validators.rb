module CareerRecordValidators
  class CareerRecordValidator < ActiveModel:: Validator
    def validate(record)
      if  record.career_end && record.career_begin > record.career_end
        record.errors[:base] << "career_begin > career_end"
      end
      # if  record.career_end && !record.user.career_records.where.not(id: record.id).empty? && (!record.user.career_records.where.not(id: record.id).where("career_end is not null").by_search_for_one_day(record.career_begin).empty? || !record.user.career_records.where.not(id: record.id).where("career_end is not null").by_search_for_one_day(record.career_end).empty? ||
      #   !record.user.career_records.where.not(id: record.id).where("(career_begin >= :begin AND career_begin <= :end AND career_end is not null) OR (career_begin >= :begin AND career_end <= :end)", begin: record.career_begin, end: record.career_end).empty?)
      #   record.errors[:base] << "has had career_record from: #{record.career_begin} to: #{record.career_end}"
      # end
      #
      # if record.career_end.nil?  && !record.user.career_records.where.not(id: record.id).empty? && (!record.user.career_records.where.not(id: record.id).where("career_end is not null").by_search_for_one_day(record.career_begin).empty? ||
      #   !record.user.career_records..where.not(id: record.id).where("career_begin >= :begin OR career_end >= :begin", begin: record.career_begin ).empty?)
      #   record.errors[:base] << "has had career_record from: #{record.career_begin} to: #{record.career_end}"
      # end
    end
  end
end