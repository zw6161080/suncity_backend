# == Schema Information
#
# Table name: positions
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  number              :string
#  grade               :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  simple_chinese_name :string
#
# Indexes
#
#  index_positions_on_parent_id  (parent_id)
#

class Position < ApplicationRecord
  has_closure_tree
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :users
  has_many :jobs
  has_many :users

  include TreeAble
  after_save :compute_number

  enum status: [:enabled, :disabled]

  def self.load_predefined
    self.find_or_create_by(id: 1) do |pos|
      pos.chinese_name = '太陽城集團行政總裁兼董事'
      pos.english_name = 'CEO of Suncity Group'
      pos.simple_chinese_name = '太阳城集团行政总裁兼董事'
      pos.number = 1
      pos.grade = 5
      pos.comment = '人事系統管理員帳號'
      pos.region_key = 'macau'
    end
  end

  def key
    id.to_s
  end

  def compute_number
    self.update_column(:number, self.id.to_s.rjust(3, '0'))
  end

  def chinese_name
    "#{read_attribute(:chinese_name)} (#{read_attribute(:number)})"
  end

  def english_name
    "#{read_attribute(:english_name)} (#{read_attribute(:number)})"
  end

  def simple_chinese_name
    "#{read_attribute(:simple_chinese_name)} (#{read_attribute(:number)})"
  end


  def raw_chinese_name
    read_attribute(:chinese_name)
  end

  def raw_english_name
    read_attribute(:chinese_name)
  end

  def raw_simple_chinese_name
    read_attribute(:simple_chinese_name)
  end


  def employees_count
    users.count
  end

end
