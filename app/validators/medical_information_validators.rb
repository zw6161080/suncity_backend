module MedicalInformationValidators
  class CurrentStatusWithMedicalTemplateValidator < ActiveModel:: Validator
    def validate(record)
      if record.current_status == 'join' && (record.medical_template_id.nil? || record.join_date.nil?)
        record.errors[:base] << 'This medical_inforamtion lacks medical_template or join_date'
      end
      if record.current_status == 'unjoin' && (record.medical_template_id   && record.join_date)
        record.errors[:base] << 'This medical_inforamtion should not has medical_template or join_date'
      end
      if !((record.to_status.nil? &&  record.valid_date.nil?) && (!record.to_status.nil? && !record.valid_date.nil?))
        record.errors[:base] << 'This medical_informamtion has wrong with to_status and valid_date '
      end
    end
  end
end