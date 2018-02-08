# == Schema Information
#
# Table name: occupation_tax_settings
#
#  id                :integer          not null, primary key
#  deduct_percent    :decimal(10, 2)
#  favorable_percent :decimal(10, 2)
#  ranges            :jsonb
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class OccupationTaxSetting < ApplicationRecord
  def self.load_predefined
    self.first_or_create(Config.get('occupation_tax_setting')['default'])
  end

  def self.reset_predefined
    predefined_config = Config.get('occupation_tax_setting')['default']
    if self.first.nil?
      self.create(predefined_config)
    else
      self.first.update(predefined_config)
    end
  end
end
