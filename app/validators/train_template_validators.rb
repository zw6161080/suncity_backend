module TrainTemplateValidators
  class AssessmentMethodWithRightExamFormatAndExamTemplateIdValidator <ActiveModel:: Validator
    def validate(record)
      if record.assessment_method == 'by_test_scores' &&( record.exam_format.blank? || (record.exam_format =='online' && record.exam_template_id.blank?))
        record.errors[:base] << 'This train_template lacks exam_format or exam_template_id when assessment_method is by_test_scores or exam_format is online'
      elsif record.assessment_method == 'by_both' &&( record.exam_format.blank? || (record.exam_format =='online' && record.exam_template_id.blank?))
        record.errors[:base] << 'This train_template lacks exam_format or exam_template_id when assessment_method is by_both or exam_format is online'
      end
    end
  end
end