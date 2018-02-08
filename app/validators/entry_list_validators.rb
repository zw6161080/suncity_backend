module EntryListValidators
  class EntryListWithUserLimitValidator < ActiveModel:: Validator
    def validate(record)
      if EntryList.where(train_id: record.train_id, user_id: record.user_id).count > 0
        record.errors[:base] << "The #{record.user_id} user_id has in the entry_list"
      end
    end
  end
end
