# == Schema Information
#
# Table name: card_histories
#
#  id                      :integer          not null, primary key
#  date_to_get_card        :date
#  new_approval_valid_date :date
#  card_valid_date         :date
#  certificate_valid_date  :date
#  new_or_renew            :string
#  card_profile_id         :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_card_histories_on_card_profile_id  (card_profile_id)
#
# Foreign Keys
#
#  fk_rails_f45e40adcf  (card_profile_id => card_profiles.id)
#

class CardHistory < ApplicationRecord
  belongs_to :card_profile

  def is_valid_record?
    self.card_profile.card_histories.last == self
  end
end
