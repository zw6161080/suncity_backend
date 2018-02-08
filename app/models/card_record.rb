# == Schema Information
#
# Table name: card_records
#
#  id              :integer          not null, primary key
#  key             :string
#  action_type     :string
#  current_user_id :integer
#  field_key       :string
#  file_category   :string
#  value1          :json
#  value2          :json
#  value           :json
#  card_profile_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_card_records_on_card_profile_id  (card_profile_id)
#  index_card_records_on_current_user_id  (current_user_id)
#
# Foreign Keys
#
#  fk_rails_609a352166  (card_profile_id => card_profiles.id)
#

class CardRecord < ApplicationRecord
  belongs_to :card_profile
  belongs_to :current_user, :class_name => "User", :foreign_key => "current_user_id"
  validates :key, inclusion: { in: %w(create_profile card_history_information
                                      card_attachment_information employ_information
                                      quota_information certificate_information street_paper_information
                                      card_information comment_information)}

end
