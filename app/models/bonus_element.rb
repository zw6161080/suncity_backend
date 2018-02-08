# == Schema Information
#
# Table name: bonus_elements
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  key                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  levels              :jsonb
#  unit                :string
#  order               :integer
#  subtypes            :jsonb
#

class BonusElement < ApplicationRecord
  has_many :bonus_element_settings, dependent: :destroy
  has_many :bonus_element_month_amounts, dependent: :destroy
  has_many :bonus_element_month_shares, dependent: :destroy

  after_save :create_all_related_settings

  def self.load_predefined
    bonus_elements_config = Config.get('bonus_elements')
    bonus_elements_config.each do |key, value|
      BonusElement.find_or_create_by(key: key).update(value.except('value_type'))
    end
  end

  # 如果新创建/更新了场馆/部门，都会重新执行
  def self.recreate_all_settings
    BonusElement.all.each do |elem|
      elem.create_all_related_settings
    end
  end

  def self.reset_all_settings
    BonusElement.all.each do |elem|
      elem.create_all_related_settings(reset: true)
    end
  end

  def create_all_related_settings(reset: false)
    bonus_elements_config = Config.get('bonus_elements')

    Location.with_departments.each do |location|
      location['departments'].each do |department|
        setting = self.bonus_element_settings.find_or_create_by(
          department_id: department['id'],
          location_id: location['id']
        ) do |setting|
          setting.value = bonus_elements_config[setting.bonus_element.key].with_indifferent_access[:value_type].to_sym rescue :departmental
        end

        if reset
          setting.value = bonus_elements_config[setting.bonus_element.key].with_indifferent_access[:value_type].to_sym rescue :departmental
          setting.save!
        end
      end
    end
  end
end
