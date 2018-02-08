# == Schema Information
#
# Table name: regions
#
#  key          :string           not null, primary key
#  chinese_name :string
#  english_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Region < ApplicationRecord
  def self.load_predefined
    Region.find_or_create_by(key: 'macau') do |region|
      region.chinese_name = '澳门'
      region.english_name = 'Macau'
    end

    Region.find_or_create_by(key: 'manila') do |region|
      region.chinese_name = '马尼拉'
      region.english_name = 'Manila'
    end
  end
end

