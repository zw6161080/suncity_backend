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

require 'test_helper'

class CardHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
