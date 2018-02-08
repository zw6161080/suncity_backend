# == Schema Information
#
# Table name: award_records
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  year       :datetime
#  content    :string
#  award_date :datetime
#  comment    :string
#  creator_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  reason     :string
#
# Indexes
#
#  index_award_records_on_creator_id  (creator_id)
#  index_award_records_on_user_id     (user_id)
#

class AwardRecord < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  after_save :update_year

  def update_year
    if self.year != self.award_date.beginning_of_year
      self.update_columns(year: self.award_date.beginning_of_year)
    end
  end
end
