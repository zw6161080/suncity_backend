module WelfareTemplateValidators
  class WelfareTemplateValidator  < ActiveModel:: Validator
    def validate(record)
      result = record.validate_belongs_to
      unless result[:tag]
        record.errors[:belongs_to] << result[:message]
      end
    end
  end
end