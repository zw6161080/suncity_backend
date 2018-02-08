# == Schema Information
#
# Table name: roster_settings
#
#  id                  :integer          not null, primary key
#  roster_id           :integer
#  shift_interval_hour :jsonb
#  rest_number         :jsonb
#  rest_interval_day   :jsonb
#  shift_type_number   :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_roster_settings_on_roster_id  (roster_id)
#
# Foreign Keys
#
#  fk_rails_d7233df600  (roster_id => rosters.id)
#

class RosterSetting < ApplicationRecord
  belongs_to :roster

  before_save :validate_setting

  def positions
    self.roster.department.positions
  end
  
  def validate_setting
    self.shift_interval_hour = knock_out_unvalidate_position_ids(self.shift_interval_hour)
    self.rest_number = knock_out_unvalidate_position_ids(self.rest_number)
    self.rest_interval_day = knock_out_unvalidate_position_ids(self.rest_interval_day)
    self.shift_type_number = knock_out_unvalidate_position_ids(self.shift_type_number)
  end

  def knock_out_unvalidate_position_ids(setting_hash)
    position_ids = self.positions.pluck(:id)
    setting_hash = setting_hash.to_h
    setting_hash.select{|k,v| position_ids.include?(k.to_i) }
  end

end
