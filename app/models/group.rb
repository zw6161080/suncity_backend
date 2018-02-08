# == Schema Information
#
# Table name: groups
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  region_key          :string
#  can_be_destroy      :boolean          default(TRUE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Group < ApplicationRecord
  has_and_belongs_to_many :departments
  has_many :users
  include TreeAble

  validates :chinese_name, :english_name, :simple_chinese_name, presence: true
  scope :by_department_id, lambda{|department_id|
     where(id: joins(:departments).where(departments: {id: department_id}).ids) if department_id && !department_id.empty?
  }
end
