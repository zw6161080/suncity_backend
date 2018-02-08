# == Schema Information
#
# Table name: roster_interval_preferences
#
#  id                   :integer          not null, primary key
#  roster_preference_id :integer
#  position_id          :integer
#  interval_hours       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_roster_interval_preferences_on_roster_preference_id  (roster_preference_id)
#

class RosterIntervalPreference < ApplicationRecord
  belongs_to :roster_preference

  def position_detail
    self.position_id != nil ? Position.find(self.position_id) : nil
  end
end
