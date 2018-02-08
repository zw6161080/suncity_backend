# == Schema Information
#
# Table name: general_holiday_interval_preferences
#
#  id                   :integer          not null, primary key
#  roster_preference_id :integer
#  position_id          :integer
#  max_interval_days    :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  interval_preferences_roster_preference_index  (roster_preference_id)
#

class GeneralHolidayIntervalPreference < ApplicationRecord
  belongs_to :roster_preference

  def position_detail
    self.position_id != nil ? Position.find(self.position_id) : nil
  end
end
