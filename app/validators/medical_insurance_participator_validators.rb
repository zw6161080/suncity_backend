module MedicalInsuranceParticipatorValidators
  class ParticipateWithMedicalTemplateValidator < ActiveModel:: Validator
    def validate(record)
      if !((record.to_status.nil? &&  record.valid_date.nil?) || (!record.to_status.nil? && !record.valid_date.nil?))
        record.errors[:base] << 'This medical_insurance_participator has wrong with to_status and valid_date '
      end
    end
  end
end