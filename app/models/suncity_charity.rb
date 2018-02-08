# == Schema Information
#
# Table name: suncity_charities
#
#  id             :integer          not null, primary key
#  current_status :string
#  to_status      :string
#  valid_date     :date
#  profile_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SuncityCharity < ApplicationRecord
  validates :current_status,  inclusion: { in: %w(join unjoin) }

  def add_to_status(to_status, valid_date)
    self.update(to_status: to_status, valid_date: valid_date)
  end

  def update_current_status(to_status)
    self.update(current_status: to_status, to_status: nil, valid_date: nil)
  end
end
