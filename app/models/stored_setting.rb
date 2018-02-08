# == Schema Information
#
# Table name: stored_settings
#
#  id         :integer          not null, primary key
#  var        :string           not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_stored_settings_on_var  (var) UNIQUE
#

class StoredSetting < ApplicationRecord

  def self.fetch(var)
    setting = self.find_or_create_by(var: var)
    setting.value
  end

  def self.update_key(var, value)
    setting = self.find_or_create_by(var: var)
    setting.value = value
    setting.save
  end
  
end
