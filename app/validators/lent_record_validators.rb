module LentRecordValidators
  class UserCanLentRecordValidator < ActiveModel:: Validator
    def validate(record)
      unless LentRecord.can_lent_by_department?(ProfileService.department(record.user, record.lent_begin).id, record.temporary_stadium_id)
        record.errors[:base] << "已選場館內沒有相關部門，無法進行暫借/調館"
      end
      if  record.lent_end && record.lent_begin > record.lent_end
        record.errors[:base] << "lent_begin > lent_end"
      end

      if  record.lent_begin < record.career_record.career_begin || (record.career_record.career_end && record.lent_begin> record.career_record.career_end)
        record.errors[:base] << "lent_begin is out career_record{ from: #{record.career_record.career_begin}, to: #{record.career_record.career_end}}"
      end

      if (record.lent_end && record.lent_end < record.career_record.career_begin) || (record.career_record.career_end && record.lent_end> record.career_record.career_end)
        record.errors[:base] << "lent_end is out career_record{ from: #{record.career_record.career_begin}, to: #{record.career_record.career_end}}"
      end

      if  record.lent_end && !record.career_record.lent_records.where.not(id: record.id).empty? && (!record.career_record.lent_records.where.not(id: record.id).where("lent_end is not null").by_search_for_one_day(record.lent_begin).empty? ||
        !record.career_record.lent_records.where.not(id: record.id).where("lent_end is not null").by_search_for_one_day(record.lent_end).empty? ||
        !record.user.lent_records.where.not(id: record.id).where("(lent_begin >= :begin AND lent_begin <= :end AND lent_end is not null) OR (lent_end >= :begin AND lent_end <= :end)", begin: record.lent_begin, end: record.lent_end).empty?)
        record.errors[:base] << "has had lent_record from: #{record.lent_begin} to: #{record.lent_end}"
      end

      if record.lent_end.nil?  && !record.career_record.lent_records.where.not(id: record.id).empty? && (!record.career_record.lent_records.where.not(id: record.id).where("lent_end is not null").by_search_for_one_day(record.lent_begin).empty? ||
        !record.user.lent_records.where.not(id: record.id).where("lent_begin >= :begin OR lent_end >= :begin", begin: record.lent_begin ).empty?)
        record.errors[:base] << "has had lent_record from: #{record.lent_begin} to: #{record.lent_end}"
      end

      if  record.career_record.museum_records.where(date_of_employment: record.lent_begin).count > 1
        record.errors[:base] << "the day has a museum_record"
      end
      if record.career_record.lent_records.where.not(id: record.id).where(lent_begin: record.lent_begin).count > 1
        record.errors[:base] << "the day has a lent_record"
      end
    end
  end
end