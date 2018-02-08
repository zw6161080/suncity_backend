module WelfareRecordValidators
  class WelfareRecordValidator < ActiveModel:: Validator
    def validate(record)
      if  record.welfare_end && record.welfare_begin > record.welfare_end
        record.errors[:base] << "welfare_begin > welfare_end"
      end
      if  record.welfare_end && !record.user.welfare_records.where.not(id: record.id).empty? && (!record.user.welfare_records.where.not(id: record.id).where("welfare_end is not null").by_search_for_one_day(record.welfare_begin).empty? || !record.user.welfare_records.where.not(id: record.id).where("welfare_end is not null").by_search_for_one_day(record.welfare_end).empty? ||
        !record.user.welfare_records.where.not(id: record.id).where("(welfare_begin >= :begin AND welfare_begin <= :end AND welfare_end is not null) OR (welfare_end >= :begin AND welfare_end <= :end)", begin: record.welfare_begin, end: record.welfare_end).empty?)
        record.errors[:base] << "has had welfare_record from: #{record.welfare_begin} to: #{record.welfare_end}"
      end

      if record.welfare_end.nil?  && !record.user.welfare_records.where.not(id: record.id).empty? && (!record.user.welfare_records.where.not(id: record.id).where("welfare_end is not null").by_search_for_one_day(record.welfare_begin).empty? ||
        !record.user.welfare_records.where.not(id: record.id).where("welfare_begin >= :begin OR welfare_end >= :begin", begin: record.welfare_begin ).empty?)
        record.errors[:base] << "has had welfare_record from: #{record.welfare_begin} to: #{record.welfare_end}"
      end
    end
  end
end