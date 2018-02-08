# == Schema Information
#
# Table name: love_fund_records
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  participate       :boolean
#  participate_begin :datetime
#  participate_end   :datetime
#  creator_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_love_fund_records_on_creator_id  (creator_id)
#

class LoveFundRecord < ApplicationRecord
  validates :participate, inclusion: {in: [true, false]}
  validates :participate_begin, :creator_id, presence: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  after_create :update_other_records
  def update_other_records
    LoveFundRecord.where(user_id: self.user_id).order(created_at: :desc)&.second&.update_columns(participate_end: self.participate_begin)
  end
end
