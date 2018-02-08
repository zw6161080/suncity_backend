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

FactoryGirl.define do
  factory :card_history do
    date_to_get_card "2017-05-15"
    new_approval_valid_date "2017-05-15"
    card_valid_date "2017-05-15"
    certificate_valid_date "2017-05-15"
    new_or_renew "新辦證"
    card_profile nil
  end
end
