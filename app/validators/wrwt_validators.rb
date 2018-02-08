module WrwtValidators
  class UserWithoutWrwtValidator < ActiveModel:: Validator
    def validate(record)
      if Wrwt.where(user_id: record.user_id).count >= 1
        record.errors[:base] << "This user_id: #{record.user_id} had a wrwt"
      end

    end
  end
end