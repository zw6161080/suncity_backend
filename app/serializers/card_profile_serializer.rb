class CardProfileSerializer < ActiveModel::Serializer
  attributes *(CardProfile.columns.map(&:name)-['created_at', 'updated_at', 'comment', 'original_user', 'date_to_stamp', 'date_to_submit_certificate'])
  def entry_date
    object.entry_date&.strftime('%Y/%m/%d')
  end

  def allocation_valid_date
    object.allocation_valid_date&.strftime('%Y/%m/%d')
  end

  def date_to_submit_data
    object.date_to_submit_data&.strftime('%Y/%m/%d')
  end

  def date_to_submit_fingermold
    object.date_to_submit_fingermold&.strftime('%Y/%m/%d')
  end

  def cancel_date
    object.cancel_date&.strftime('%Y/%m/%d')
  end

  def new_approval_valid_date
    object.new_approval_valid_date&.strftime('%Y/%m/%d')
  end

  def certificate_valid_date
    object.certificate_valid_date&.strftime('%Y/%m/%d')
  end

  def date_to_get_card
    object.date_to_get_card&.strftime('%Y/%m/%d')
  end

  def card_valid_date
    object.card_valid_date&.strftime('%Y/%m/%d')
  end
end