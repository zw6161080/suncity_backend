# == Schema Information
#
# Table name: whether_together_preferences
#
#  id                   :integer          not null, primary key
#  roster_preference_id :integer
#  group_name           :string
#  group_members        :integer          default([]), is an Array
#  date_range           :string
#  start_date           :date
#  end_date             :date
#  comment              :text
#  is_together          :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_whether_together_preferences_on_roster_preference_id  (roster_preference_id)
#

class WhetherTogetherPreference < ApplicationRecord
  belongs_to :roster_preference
end
