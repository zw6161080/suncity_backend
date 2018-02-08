# == Schema Information
#
# Table name: bonus_element_settings
#
#  id               :integer          not null, primary key
#  department_id    :integer
#  location_id      :integer
#  bonus_element_id :integer
#  value            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_bonus_element_settings_on_bonus_element_id  (bonus_element_id)
#  index_bonus_element_settings_on_department_id     (department_id)
#  index_bonus_element_settings_on_location_id       (location_id)
#
# Foreign Keys
#
#  fk_rails_cb58d39bcf  (bonus_element_id => bonus_elements.id)
#  fk_rails_d5a353db08  (department_id => departments.id)
#  fk_rails_de95acbaae  (location_id => locations.id)
#

class BonusElementSetting < ApplicationRecord
  belongs_to :department
  belongs_to :location
  belongs_to :bonus_element

  enum value: { departmental: 'departmental', personal: 'personal' }

  def self.batch_update(updates)
    ActiveRecord::Base.transaction do
      updates.each do |params|
        self.find_or_create_by(
          department_id: params[:department_id],
          location_id: params[:location_id],
          bonus_element_id: params[:bonus_element_id]
        ).update(value: params[:value])
      end
    end
  end

end
