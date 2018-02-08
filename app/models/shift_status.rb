# == Schema Information
#
# Table name: shift_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  profile_id :integer
#  is_shift   :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_shift_statuses_on_user_id  (user_id)
#

class ShiftStatus < ApplicationRecord
  belongs_to :user

  def self.create_with_params(user_id, shift_status_params)
    ss = ShiftStatus.create(shift_status_params)
    ss.user_id = user_id
    ss.save!
  end

  def self.create_default_one(user_id)
    ShiftStatus.create(user_id: user_id, is_shift: true)
  end
end
