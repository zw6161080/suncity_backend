module TrainClassValidators
  class TrainClassWithRightTitleValidator <ActiveModel:: Validator
    def validate(record)
      if record.title.nil?
        record.errors[:base] << "This class doesn't select  title"
      end
    end
  end
end