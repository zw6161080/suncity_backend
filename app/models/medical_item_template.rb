# == Schema Information
#
# Table name: medical_item_templates
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  can_be_delete       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class MedicalItemTemplate < ApplicationRecord
  has_many :medical_items
end
