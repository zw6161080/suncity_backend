# == Schema Information
#
# Table name: goods_category_managements
#
#  id                  :integer          not null, primary key
#  chinese_name        :string           not null
#  english_name        :string           not null
#  simple_chinese_name :string           not null
#  unit                :string           not null
#  unit_price          :decimal(10, 2)   not null
#  distributed_number  :integer
#  collected_number    :integer
#  unreturned_number   :integer
#  creator_id          :integer
#  create_date         :datetime
#  can_be_delete       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_goods_category_managements_on_chinese_name         (chinese_name)
#  index_goods_category_managements_on_collected_number     (collected_number)
#  index_goods_category_managements_on_create_date          (create_date)
#  index_goods_category_managements_on_creator_id           (creator_id)
#  index_goods_category_managements_on_distributed_number   (distributed_number)
#  index_goods_category_managements_on_english_name         (english_name)
#  index_goods_category_managements_on_simple_chinese_name  (simple_chinese_name)
#  index_goods_category_managements_on_unit                 (unit)
#  index_goods_category_managements_on_unit_price           (unit_price)
#  index_goods_category_managements_on_unreturned_number    (unreturned_number)
#
# Foreign Keys
#
#  fk_rails_d6a378e5c6  (creator_id => users.id)
#

class GoodsCategoryManagement < ApplicationRecord
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'

  validates :chinese_name, :english_name, :simple_chinese_name, :unit, :unit_price, presence: true

  scope :by_unit, lambda { |unit|
    where(unit: unit)
  }

  scope :by_unit_price, lambda { |unit_price|
    where(unit_price: unit_price)
  }

  scope :by_distributed_number, lambda { |distributed_number|
    where(distributed_number: distributed_number)
  }

  scope :by_collected_number, lambda { |collected_number|
    where(collected_number: collected_number)
  }

  scope :by_unreturned_number, lambda { |unreturned_number|
    where(unreturned_number: unreturned_number)
  }

  scope :by_creator_id, lambda { |creator_id|
    where(creator_id: creator_id)
  }

end
