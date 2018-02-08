# == Schema Information
#
# Table name: classes_between_general_holiday_preferences
#
#  id                   :integer          not null, primary key
#  roster_preference_id :integer
#  position_id          :integer
#  max_classes_count    :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  roster_preference_index  (roster_preference_id)
#

class ClassesBetweenGeneralHolidayPreference < ApplicationRecord
  belongs_to :roster_preference

  def position_detail
    self.position_id != nil ? Position.find(self.position_id) : nil
  end
end
