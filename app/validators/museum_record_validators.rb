module MuseumRecordValidators
  class MuseumRecordValidator < ActiveModel:: Validator
    def validate(record)
      if  record.date_of_employment < record.career_record.career_begin || record.date_of_employment > record.career_record.career_end
        record.errors[:base] << "date_of_employment is out career_record{ from: #{record.career_record.career_begin}, to: #{record.career_record.career_end}}"
      end
      if  record.career_record.museum_records.where.not(id: record.id).where(date_of_employment: record.date_of_employment).count > 1
        record.errors[:base] << "the day has a museum_record"
      end
      if record.career_record.lent_records.where(lent_begin: record.date_of_employment).count > 1
        record.errors[:base] << "the day has a lent_record"
      end
    end
  end
end