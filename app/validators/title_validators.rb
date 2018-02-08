module TitleValidators
  class TitleWithRightRowValidator <ActiveModel:: Validator
    def validate(record)
      if  record.train.titles.where.not(id: record.id).pluck(:col).include? record.col
        record.errors[:base] << "This train #{record.col} has been set"
      end
    end

  end
end