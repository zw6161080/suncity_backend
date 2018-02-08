# == Schema Information
#
# Table name: roster_model_weeks
#
#  id                   :integer          not null, primary key
#  region               :string
#  roster_model_id      :integer
#  order_no             :integer
#  mon_class_setting_id :integer
#  tue_class_setting_id :integer
#  wed_class_setting_id :integer
#  thu_class_setting_id :integer
#  fri_class_setting_id :integer
#  sat_class_setting_id :integer
#  sun_class_setting_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_roster_model_weeks_on_roster_model_id  (roster_model_id)
#

class RosterModelWeek < ApplicationRecord
  belongs_to :roster_model
end
