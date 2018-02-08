# == Schema Information
#
# Table name: card_attachments
#
#  id              :integer          not null, primary key
#  category        :string
#  file_name       :string
#  comment         :text
#  attachment_id   :integer
#  card_profile_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  operator_id     :integer
#
# Indexes
#
#  index_card_attachments_on_card_profile_id  (card_profile_id)
#
# Foreign Keys
#
#  fk_rails_7014c26eff  (card_profile_id => card_profiles.id)
#

class CardAttachment < ApplicationRecord
  belongs_to :card_profile
end
