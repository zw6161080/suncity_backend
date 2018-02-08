# == Schema Information
#
# Table name: class_people_preferences
#
#  id                    :integer          not null, primary key
#  roster_preference_id  :integer
#  class_setting_id      :integer
#  max_of_total          :integer
#  min_of_total          :integer
#  max_of_manager_level  :integer
#  min_of_manager_level  :integer
#  max_of_director_level :integer
#  min_of_director_level :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_class_people_preferences_on_roster_preference_id  (roster_preference_id)
#

class ClassPeoplePreference < ApplicationRecord
  belongs_to :roster_preference
  has_one :class_setting

  def class_setting_detail
    self.class_setting_id != nil ? ClassSetting.find_by(id: self.class_setting_id) : nil
  end
end
